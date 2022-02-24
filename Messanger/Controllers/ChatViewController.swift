//
//  ChatViewController.swift
//  Messanger
//
//  Created by admin on 11/1/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import PhotosUI

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

public struct Media: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
}

extension MessageKind {
    /// discribes the types of the choosen message
    var messageKindString: String {
        switch self {
        case .text(let string):
            return "text \(string)"
        case .attributedText(let nSAttributedString):
            return "attributed_text \(nSAttributedString)"
        case .photo(_):
            return  "photo"
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
    

    
    public  let barButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        return button
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
        messagesCollectionView.messageCellDelegate = self
       messageInputBar.delegate = self
        setUpBarButton()
    }

    private func setUpBarButton() {
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([barButton], forStack: .left, animated: false)
        barButton.onTouchUpInside { [weak self] _ in
            self?.attachButtonClicked()
        }
        
    }
    
    func attachButtonClicked() {
        ImagePickerManager().pickImage(self) { [weak self] image, video  in
            guard let photoMessageId = self?.createMessageIdRandomizer(),
                  let conversationID = self?.conversationID,
                  let name = self?.title,
                  let sender = self?.selfSender
            else { return }
            
            if image != nil, let imageData = image?.pngData() {
                let fileName =  "photo_message_" + photoMessageId.replacingOccurrences(of: " ", with: "-") + ".png"
                // Upload image
                StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName ) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let urlString):
                        // send message here
                        guard let url = URL(string: urlString),
                              let placeHolder = UIImage(systemName: "photo") else {
                                  return
                              }
                        
                        let media = Media(url: url,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: .zero)
                        
                        let message = Message(sender: sender ,
                                              messageId: photoMessageId,
                                              sentDate: Date(),
                                              kind: .photo(media))
                        
                        DatabaseManager.shared.sendMessage(to: conversationID, name:  name, otherUserEmail: strongSelf.otherUserEmail, messageParam: message) { succsess in
                            if succsess {
                                print("photo message sent: ")
                                
                            } else {
                                print("failed send photo message: ")
                                
                            }
                        }
                    case .failure(let error):
                        print("failed to load URL \(error)")
                    }
                    
                }
            }
            else if  video != nil {
                let fileName =  "photo_message_" + photoMessageId.replacingOccurrences(of: " ", with: "-") + ".mov"
                
                
                
            }
           
        }
    
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let mediaItem):
            guard let imageURL = mediaItem.url else {
                return
            }
            imageView.sd_setImage(with: imageURL, completed: nil)
            
        default:
            break
        }
    }
}

extension ChatViewController:  MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let mediaItam):
            guard let url = mediaItam.url else {
                return
            }
            let vc = PhotoViewerViewController(with: url)
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
