import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotchController.shared.attach(engine: .shared)
    }
}

@main
struct ClaudeUsageTrayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var engine = UsageEngine.shared
    @StateObject private var notch = NotchController.shared

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(engine)
                .environmentObject(notch)
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
