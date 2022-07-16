import SwiftUI
import UserNotifications

struct ContentView: View {
    @Environment(\.messagesListener) var messagesListener: MessagesListener
    @State var userMessage: String = ""
    @State var showQuit: Bool = true
    
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
        .frame(width: 500, height: 200, alignment: Alignment.center)
        .padding()
        .border(.bar, width: 1)
        .onAppear(perform: {
            if (messagesListener.isListening()) {
                userMessage = "Listening for new messages"
            } else {
                userMessage = "Failed to start watching messages directory. Most likely, you need to grant full disk access"
            }
        })
            
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
