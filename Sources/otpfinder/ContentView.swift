import SwiftUI



func sendNotification(title: String, body: String = "") {
}


struct ContentView: View {
    let messagesListener = MessagesListener()

    @State var userMessage: String
    @State var showQuit: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 3, content: {
            Text(userMessage)
                .padding()
                .border(.bar, width: 1)
            
            if (showQuit) {
                Button("Quit App", action: {
                    exit(0)
                })
            }
        })
        .padding()
        .border(.bar, width: 1)
        .onAppear(perform: {
            do {
                try messagesListener.startListening(onMessages:onMessageReceived)
                userMessage = "Listening for new messages"
            } catch {
                print(error)
                let errorMsg = "Failed to start watching messages directory. Most likely, you need to grant full disk access"
                print(errorMsg)

                userMessage = errorMsg;
                showQuit = true;
            }
        })
            
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

