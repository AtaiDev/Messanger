//
//  ChatViewController.swift
//  Messanger
//
//  Created by admin on 11/1/22.
//

import UIKit
import MessageKit

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

class ChatViewController: MessagesViewController {
  
    private var messages = [Message]()
    let selfSender = Sender(photoURL: "",
                            senderId: "1",
                            displayName: "Gang")
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
      
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
    
        messages.append( Message(sender: selfSender,
                                 messageId: "123",
                                 sentDate: Date(),
                                 kind: .text("NOTE: If you look closely at the implementation of the messageForItem method you'll see that we use the indexPath.section to retrieve our MessageType from the array as opposed to the traditional indexPath.row property. This is because the default behavior of MessageKit is to put each MessageType is in its own section of the MessagesCollectionView.") ))
        messages.append( Message(sender: selfSender,
                                 messageId: "123",
                                 sentDate: Date(),
                                 kind: .text("What the fuck man?") ))

    }
  
}

extension ChatViewController:  MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
