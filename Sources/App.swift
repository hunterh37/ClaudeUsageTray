import SwiftUI

@main
struct ClaudeUsageTrayApp: App {
    @StateObject private var engine = UsageEngine()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(engine)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "gauge.with.dots.needle.50percent")
                Text(engine.menuTitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
        }
        .menuBarExtraStyle(.window)
    }
}
