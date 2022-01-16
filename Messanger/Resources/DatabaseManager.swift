//
//  DatabaseManager.swift
//  Messanger
//
//  Created by admin on 7/1/22.
//

import FirebaseDatabase
import UIKit
import SwiftUI

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
