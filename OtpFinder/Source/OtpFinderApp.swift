import SwiftUI
import UserNotifications


@main
struct OtpFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: Set(arrayLiteral: "ContentView"), allowing: Set(arrayLiteral: "ContentView"))
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "ContentView"))

    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    @Environment(\.openURL) var openURL
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(completionHandler: {
            (Bool, Error) in
            return
        })

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let icon = NSImage(named: "AppIcon")
        icon?.size.width = 16
        icon?.size.height = 16
        statusItem?.button?.image = icon
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(activateWindow(_:))
        
        if let window = NSApplication.shared.windows.first {
            window.close()
        }

    }
    
    @IBAction func activateWindow(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.openURL(URL(string: "otpfinder://ContentView")!)
        }
    }
}
