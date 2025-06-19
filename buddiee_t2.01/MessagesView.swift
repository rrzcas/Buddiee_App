import SwiftUI

struct MessagesView: View {
    @State private var selectedUserId: String? = nil
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    
    var body: some View {
        NavigationView {
            Group {
                if let selectedUserId = selectedUserId {
                    ChatView(
                        userId: selectedUserId,
                        messages: messages.filter { $0.senderId == selectedUserId || $0.receiverId == selectedUserId },
                        messageText: $messageText,
                        onSend: sendMessage,
                        onBack: { self.selectedUserId = nil }
                    )
                } else {
                    ConversationsList(
                        conversations: User.sampleUsers,
                        onSelectUser: { user in
                            self.selectedUserId = user.id
                        }
                    )
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, let selectedUserId = selectedUserId else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            senderId: "currentUser", // Replace with actual current user ID
            receiverId: selectedUserId,
            content: messageText,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
    }
}

struct ChatView: View {
    let userId: String
    let messages: [Message]
    @Binding var messageText: String
    let onSend: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                if let user = User.sampleUsers.first(where: { $0.id == userId }) {
                    Text(user.username)
                        .font(.headline)
                }
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.senderId == "currentUser" {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.senderId == "currentUser" ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.senderId == "currentUser" ? .white : .primary)
                .cornerRadius(20)
            
            if message.senderId != "currentUser" {
                Spacer()
            }
        }
    }
}

struct ConversationsList: View {
    let conversations: [User]
    let onSelectUser: (User) -> Void
    
    var body: some View {
        List {
            ForEach(conversations) { user in
                Button(action: { onSelectUser(user) }) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(user.username)
                                .font(.headline)
                            Text(user.location)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Messages")
    }
}
