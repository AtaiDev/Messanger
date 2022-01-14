//
//  DatabaseManager.swift
//  Messanger
//
//  Created by admin on 7/1/22.
//

import FirebaseDatabase
import UIKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
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
        database.child(appUser.safeEmail).setValue( ["first_name": appUser.firstName, "last_name": appUser.lastName] ) { error,  _ in
            guard error == nil else {
                print("failed to create user")
                complition(false)
                return
            }
            complition(true)
        }
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
