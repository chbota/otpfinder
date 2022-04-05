import AppKit
import SwiftUI

@main
struct OTPFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var contentView = ContentView(userMessage: "", showQuit: false)
    var body: some Scene {
        WindowGroup {
            contentView
        }
    }
    
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
