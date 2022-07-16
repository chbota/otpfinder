import SwiftUI
import UserNotifications

private struct MessagesListenerInstance: EnvironmentKey {
  static let defaultValue = MessagesListener()
}

extension EnvironmentValues {
  var messagesListener: MessagesListener {
    get { self[MessagesListenerInstance.self] }
  }
}


@main
struct OtpFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.messagesListener) var messagesListener;

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

func sendNotification(title: String, body: String = "") {
    DispatchQueue.main.async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let notification = UNNotificationRequest(identifier: "otpfinder", content: content, trigger:nil)
        UNUserNotificationCenter.current().add(notification)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    @Environment(\.openURL) var openURL
    @Environment(\.messagesListener) var messagesListener;

    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(completionHandler: {
            (Bool, Error) in
            return
        })

        do {
            try messagesListener.startListening(onMessages:onMessageReceived)
        } catch {
            print(error)
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let icon = NSImage(named: "AppIcon")
        icon?.size.width = 16
        icon?.size.height = 16
        icon?.isTemplate = true // recolors icon automatically for dark/light modes
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
    
    func onMessageReceived(messages: [Message]) {
        for message in messages {
            let otp = extractOneTimePassword(fromMessage: message.text);
            
            if (otp != nil) {
                print("Found code \(otp!). Adding to clipboard")
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(otp!, forType:.string)
                
                sendNotification(title:"Otp Finder", body: "Copied code")
                
                // we only care about the first code we see, otherwise we'll overwrite more recent
                // codes with older codes (messages are sorted by date desc)
                return
            }
        }
    }
}
