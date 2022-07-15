import AppKit
import SwiftUI
import UserNotifications

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

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.activate(ignoringOtherApps: true)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(completionHandler: {
            (Bool, Error) in
            return 
        })
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }
}
