//
//  StorageManager.swift
//  Messanger
//
//  Created by admin on 12/1/22.
//

import FirebaseStorage
import UIKit
import CoreMedia

final class StorageManager {
    public static let shared = StorageManager()
    
    private let  storage = Storage.storage().reference()
    public typealias UploadPictureComplition = ((Result<String, Error>) -> Void)
    
    /// uploads picture to firbase storage and returns complition with string and errore result
    public func uploadProfilePicture(with data: Data, fileName: String, complition: @escaping UploadPictureComplition) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self]  metaData, error in
            guard let strongSelf = self else { return }
            guard error == nil else {
                print("Failed to upload image to storage \(String(describing: error?.localizedDescription))")
                complition(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL { url, error in
                guard  error == nil else {
                    print("Failed to download url from the storage \(String(describing: error?.localizedDescription))")
                    complition(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                guard let urlString = url?.absoluteString else {
                    return
                }
                print("url string is here: \(urlString)")
                complition(.success(urlString))
            }
        }
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadURL
    }
    
}
