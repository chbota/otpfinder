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
        WindowGroup {}
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
        requestNotificationPermissions();
        startListeningForMessages()
        createStatusItem();

        if let window = NSApplication.shared.windows.first {
            window.close()
        }

    }
    
    @IBAction func quitApp(_ sender: AnyObject) {
        exit(0)
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(completionHandler: {
            (Bool, Error) in
            return
        })
    }

    func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let icon = NSImage(named: "AppIcon")
        icon?.size.width = 16
        icon?.size.height = 16
        icon?.isTemplate = true // recolors icon automatically for dark/light modes
        
        statusItem?.button?.image = icon
        
        let menu = NSMenu()

        let statusMenuItem = NSMenuItem()
        statusMenuItem.title = messagesListener.isListening() ? "Listening for OTPs..." : "Full disk access required!"

        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        quitMenuItem.action = #selector(quitApp(_:))
        quitMenuItem.target = self
        quitMenuItem.isEnabled = true

        menu.addItem(statusMenuItem)
        menu.addItem(quitMenuItem)

        statusItem?.menu = menu
    }

    func startListeningForMessages() {
        do {
            try messagesListener.startListening(onMessages:onMessageReceived)
        } catch {
            print(error)
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
