//
//  DatabaseManager.swift
//  Messanger
//
//  Created by admin on 7/1/22.
//

import FirebaseDatabase
import UIKit
import SwiftUI
import MessageKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func  safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
    
}

extension DatabaseManager {
    
    public func isUserExist(email: String,  complition:  @escaping  ((Bool) -> Void) ) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard  snapshot.value as? String != nil else {
                complition(false)
                return
            }
            complition(true)
        }
    }
    
    /// creates user firebase user and returns bool
    public func  addUser(appUser : ChatAppUser, complition: @escaping ((Bool) -> Void) ) {
        database.child(appUser.safeEmail).setValue( ["first_name": appUser.firstName, "last_name": appUser.lastName] ) { [weak self] error,  _ in
            guard let strongSelf = self else { return }
            guard error == nil else {
                print("failed to create user")
                complition(false)
                return
            }
            // saved to show in the profile view name lable
            UserDefaults.standard.set(appUser.firstName + " " + appUser.lastName, forKey: "name_show_profile")
            strongSelf.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [ [String: String] ]  {
                    // append to user collection
                    let newElement = [
                        "name": appUser.firstName + " " + appUser.lastName,
                        "email": appUser.safeEmail
                    ]
                    usersCollection.append(newElement)
                    strongSelf.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            complition(false)
                            return
                        }
                        complition(true)
                    }
                } else {
                    // create array
                    let newCollection : [[String: String]] = [
                        [
                            "name": appUser.firstName + " " + appUser.lastName,
                            "email": appUser.safeEmail
                        ]
                    ]
                    strongSelf.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            complition(false)
                            return
                        }
                        complition(true)
                    }
                }
            }
        }
    }
    
    public typealias FetchUserComplitionResult = ((Result<[[String: String]], Error>) -> Void )
    func fetchAllUsers(complition: @escaping FetchUserComplitionResult) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                complition(.failure(DatabaseError.failedToFetchUser))
                return
            }
            complition(.success(value))
        }
    }
    
}
public enum DatabaseError: Error {
    case failedToFetchUser
}

// MARK: - Sending messages / conversations
extension DatabaseManager {
    /*
     conversation => [
        [
            "convorsation_id": "alkdjflksflk"
            "other_user_id":
            "latest_message": => {
                "date": Date()
                "latest_message": "message"
                "is_read": true/false
            }
        ],
     ]
     */
    
    /// create new conversation with target user email and first message sent
    public func creatNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, complition: @escaping ((Bool) -> Void))  {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            complition(false)
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child(safeEmail)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                complition(false)
                print("User not found:")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            let newConversation : [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message":  [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            let recipient_newConversation : [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": "Participiant",
                "latest_message":  [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            // Update recipient conversation
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append the new element
                    conversations.append(recipient_newConversation)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationID)
                }
                else {
                    // create the element
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversation])
                    
                }
                
            }
            // Update current user conversation
            if var conversations = userNode["conversations"] as? [[String: Any]]  {
                //conversation exist for user append
                conversations.append(newConversation)
                userNode["conversations"] = conversations
                ref.setValue(newConversation) { [weak self] error, _  in
                    guard  error == nil else {
                        complition(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                     complition:complition)
                }
            }
            else {
                // create conversation
                userNode["conversations"] = [
                    newConversation
                ]
            }
            
            ref.setValue(userNode) { [weak self] error, _  in
                guard  error == nil else {
                    complition(false)
                    return
                }
                self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, complition:complition)
            }
            
        }

    }
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
//        "alkdjflksflk" {
//           "messages": [
//               "id": String,
//               "type": text, photo, video, location, contact,
//               "content": String
//               "date": Date()
//               "sender_email": String,
//               "isRead": true/false
//           ]
//        }
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            complition(false)
            return
        }
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content":  message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]

        database.child(conversationID).setValue(value) { error, _ in
            guard error == nil else {
                complition(false)
                return
            }
            complition(true)
        }
    }
    
    /// Fetchaes and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, complition : @escaping ((Result<[Conversation], Error>) -> (Void)) ) {
        print("email let's see ========== \(email)")
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                complition(.failure(DatabaseError.failedToFetchUser))
                return
            }
            
            let conversations : [Conversation] = value.compactMap({ dictionary in
                guard let coversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          return nil
                      }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                return Conversation(id: coversationID,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            complition(.success(conversations))
        }
        
    
    }
    /// Gets all messages for given conversationID
    public func getAllMessagesForConversation(with id: String, complition: @escaping (Result<[Message], Error>) -> Void ) {
        
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                complition(.failure(DatabaseError.failedToFetchUser))
                return
            }
            let messages : [Message] = value.compactMap({ dictionary in
                guard let content = dictionary["content"] as? String,
                      let id = dictionary["id"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let name = dictionary["name"] as? String,
                      let sender_email = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = dictionary["date"] as?  String,
                      let dateFormatted = ChatViewController.dateFormatter.date(from: date) else {
                          return nil
                      }
                let safeEmail = DatabaseManager.safeEmail(emailAddress: sender_email)
                let sender = Sender(photoURL: "",
                                    senderId: safeEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: id,
                               sentDate: dateFormatted,
                               kind: .text(content))
            })
            complition(.success(messages))
        }
    }
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, complition: @escaping (Bool) -> Void) {
        
    }
    
    
}


struct ChatAppUser {
    let emailAddress: String,
        firstName: String,
        lastName: String
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
