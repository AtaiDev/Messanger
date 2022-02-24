//
//  ChatViewController.swift
//  Messanger
//
//  Created by admin on 11/1/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

public struct Sender: SenderType {
    var photoURL: String
    public var senderId: String
    public var displayName: String
}

public struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    /// discribes the types of the choosen message
    var messageKindString: String {
        switch self {
        case .text(let string):
            return "text \(string)"
        case .attributedText(let nSAttributedString):
            return "attributed_text \(nSAttributedString)"
        case .photo(let mediaItem):
            return "photo \(mediaItem)"
        case .video(let mediaItem):
            return "video \(mediaItem)"
        case .location(let locationItem):
            return "location \(locationItem)"
        case .emoji(let string):
            return "emoji \(string)"
        case .audio(let audioItem):
            return "audio \(audioItem)"
        case .contact(let contactItem):
            return "contact \(contactItem)"
        case .linkPreview(let linkItem):
            return "linkPreview \(linkItem)"
        case .custom(let optional):
            return "custom \(optional)"
        }
    }
    
}

class ChatViewController: MessagesViewController {
  
    public static let dateFormatter: DateFormatter = {
        let date = DateFormatter()
        date.dateStyle = .medium
        date.timeStyle = .long
        date.locale = .current
        return date
    }()
    
    public let otherUserEmail: String
    private let conversationID: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
               senderId: safeSenderEmail,
               displayName: "Me")
        
    }
    
    init( with email: String, id: String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        if let conversationID = conversationID {
            startListeningMessages(withID: conversationID, shouldScrollToBottom: true)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       messagesCollectionView.messagesLayoutDelegate = self
       messagesCollectionView.messagesDisplayDelegate = self
       messagesCollectionView.messagesDataSource = self
       messageInputBar.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
    }
    
    func startListeningMessages(withID conversationID: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: conversationID) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                }
            case .failure(let error):
                print("failed to fetch messages \(error.localizedDescription)")
            }
        }
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = selfSender,
        let messageId = createMessageIdRandomizer() else {
            return
        }
        
        print("sending: \(text)")
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        if isNewConversation {
            // create new convo data
            DatabaseManager.shared.creatNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { succsess in
                if succsess {
                    print("message sent \(message)")
                    
                }
                else {
                    print("Failed to send message")
                }
            }
        }
        else {
            // appand to existing convo
            guard let conversationID = conversationID else {
                print("failed to obtain conversationID")
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationID, name: self.title ?? "User", otherUserEmail: otherUserEmail,
                                               messageParam: message) { success in
                if success {
                    print("message successfully uploaded and appended")
                }
                else {
                    print("failed to appand other message")
                }
            }
            
        }
    }
    
   private func createMessageIdRandomizer() -> String? {
       guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String  else {
           return nil
       }
       let dateString = Self.dateFormatter.string(from: Date())
       
       let currentSafeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
       let newIdentifier = "\(otherUserEmail)_\(currentSafeEmail)_\(dateString)"
       print("created randomized identifier: \(newIdentifier)")
       return newIdentifier
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
             case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
             default: return MessageLabel.defaultAttributes
             }
    }
    
}

extension ChatViewController:  MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email shoud be provided and saved locally")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
