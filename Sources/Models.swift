import Foundation

// MARK: - Core data types

struct TokenCounts: Codable, Equatable {
    var input: Int64 = 0
    var output: Int64 = 0
    var cacheCreate: Int64 = 0
    var cacheRead: Int64 = 0

    var total: Int64 { input + output + cacheCreate + cacheRead }
    /// Tokens excluding cache reads (cache reads are ~10x cheaper against limits)
    var billable: Int64 { input + output + cacheCreate }

    static func + (l: TokenCounts, r: TokenCounts) -> TokenCounts {
        TokenCounts(input: l.input + r.input,
                    output: l.output + r.output,
                    cacheCreate: l.cacheCreate + r.cacheCreate,
                    cacheRead: l.cacheRead + r.cacheRead)
    }
    static func += (l: inout TokenCounts, r: TokenCounts) { l = l + r }
}

struct AccountInfo: Codable, Identifiable, Equatable {
    var uuid: String
    var email: String
    var displayName: String?
    var organizationName: String?
    var rateLimitTier: String?
    var firstSeen: Date
    var lastSeen: Date

    /// User-editable limits (0 = unset)
    var fiveHourLimitTokens: Int64 = 0
    var weeklyLimitTokens: Int64 = 0
    /// Which metric limits are compared against
    var useBillableMetric: Bool = true

    var id: String { uuid }
    var shortName: String {
        if let d = displayName, !d.isEmpty { return d }
        return email.components(separatedBy: "@").first ?? email
    }

    /// 5h limit to gauge against: user value if set, else a tier estimate.
    var effectiveFiveHourLimit: Int64 {
        fiveHourLimitTokens > 0 ? fiveHourLimitTokens : TierDefaults.fiveHour(rateLimitTier)
    }
    /// Weekly limit to gauge against: user value if set, else a tier estimate.
    var effectiveWeeklyLimit: Int64 {
        weeklyLimitTokens > 0 ? weeklyLimitTokens : TierDefaults.weekly(rateLimitTier)
    }
    /// True when the effective 5h limit came from a tier estimate, not a user value.
    var fiveHourLimitIsEstimate: Bool { fiveHourLimitTokens <= 0 && effectiveFiveHourLimit > 0 }
    var weeklyLimitIsEstimate: Bool { weeklyLimitTokens <= 0 && effectiveWeeklyLimit > 0 }
}

/// Rough per-tier token windows. Anthropic does not publish exact token
/// limits, so these are estimates meant only to render a progress bar; users
/// can override per account. 0 = unknown tier (bar stays empty).
enum TierDefaults {
    private static func normalized(_ tier: String?) -> String {
        (tier ?? "").lowercased()
    }
    static func fiveHour(_ tier: String?) -> Int64 {
        let t = normalized(tier)
        if t.contains("max_20x") { return 88_000_000 }
        if t.contains("max_5x")  { return 44_000_000 }
        if t.contains("pro")     { return 19_000_000 }
        return 0
    }
    static func weekly(_ tier: String?) -> Int64 {
        let t = normalized(tier)
        if t.contains("max_20x") { return 1_760_000_000 }
        if t.contains("max_5x")  { return 880_000_000 }
        if t.contains("pro")     { return 380_000_000 }
        return 0
    }
}

/// Records when the logged-in account changed, so usage can be
/// attributed to whichever account was active at each timestamp.
struct AccountSwitch: Codable {
    var timestamp: Date
    var accountUuid: String
}

/// 5-minute usage bucket, keyed by epoch/300, per account
typealias BucketMap = [String: [Int64: TokenCounts]]  // accountUuid -> bucketKey -> counts

struct FileCursor: Codable {
    var offset: UInt64
    var size: UInt64
    var mtime: Double
}

// MARK: - Persisted state

struct PersistedState: Codable {
    var accounts: [String: AccountInfo] = [:]
    var switches: [AccountSwitch] = []
    var buckets: BucketMap = [:]
    var cursors: [String: FileCursor] = [:]          // file path -> cursor
    var seenMessages: [String: Int64] = [:]          // dedupe key -> day epoch (for pruning)
    var firstRun: Date = Date()
}

// MARK: - Window math

struct UsageWindow {
    var start: Date
    var end: Date
    var counts: TokenCounts
    var isActive: Bool
}

enum WindowMath {
    /// Claude-style anchored windows: a window opens at the first usage
    /// after the previous window expired and lasts `length`.
    /// Returns the window containing `now` (if any) computed from sorted bucket keys.
    static func currentWindow(bucketKeys: [Int64], counts: [Int64: TokenCounts],
                              length: TimeInterval, now: Date) -> UsageWindow? {
        guard !bucketKeys.isEmpty else { return nil }
        var windowStart: Int64? = nil
        for k in bucketKeys {
            let t = k * 300
            if let ws = windowStart, Double(t) < Double(ws) + length {
                continue
            }
            windowStart = t
        }
        guard let ws = windowStart else { return nil }
        let start = Date(timeIntervalSince1970: Double(ws))
        let end = start.addingTimeInterval(length)
        guard now < end else { return nil }
        var sum = TokenCounts()
        for k in bucketKeys where k * 300 >= ws && Double(k * 300) < Double(ws) + length {
            sum += counts[k] ?? TokenCounts()
        }
        return UsageWindow(start: start, end: end, counts: sum, isActive: true)
    }
}

// MARK: - Formatting helpers

func fmtTokens(_ n: Int64) -> String {
    let d = Double(n)
    switch abs(d) {
    case 1_000_000_000...: return String(format: "%.2fB", d / 1_000_000_000)
    case 1_000_000...:     return String(format: "%.1fM", d / 1_000_000)
    case 1_000...:         return String(format: "%.1fK", d / 1_000)
    default:               return "\(n)"
    }
}

func fmtCountdown(to date: Date) -> String {
    let s = max(0, Int(date.timeIntervalSinceNow))
    let h = s / 3600, m = (s % 3600) / 60
    if h > 24 { return "\(h / 24)d \(h % 24)h" }
    return h > 0 ? "\(h)h \(m)m" : "\(m)m"
}
