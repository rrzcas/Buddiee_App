import Foundation
import Combine
// import buddiee_t2_01App // Removed incorrect import
// If Message is in Models, use: import buddiee_t2_01App.Models

class MessageStore: ObservableObject {
    @Published var conversations: [String] = [] // Conversation IDs or user IDs
    @Published var messages: [Message] = []
    
    func sendMessage(_ message: Message) {}
    func fetchMessages(for conversationId: String) {}
    func markAsRead(_ message: Message) {}
} 