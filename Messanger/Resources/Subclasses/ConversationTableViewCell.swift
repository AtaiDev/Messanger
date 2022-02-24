//
//  ConversationTableViewCell.swift
//  Messanger
//
//  Created by admin on 31/1/22.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    public static let reusibleID = "ConversationTableViewCell"
    
     private let userImageView : UIImageView = {
        let imageView = UIImageView()
         imageView.contentMode = .scaleToFill
         imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    private let userName : UILabel = {
        let nameLable = UILabel()
        nameLable.font = .systemFont(ofSize: 21, weight: .bold)
        return nameLable
    }()
    
    private let userLatestMessage: UILabel = {
        let lateMessageLable = UILabel()
        lateMessageLable.font = .systemFont(ofSize: 16, weight: .light)
        return lateMessageLable
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userName)
        contentView.addSubview(userLatestMessage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 80,
                                     height: 80)
        
        userName.frame = CGRect(x: userImageView.right + 10,
                                y: 10,
                                width: contentView.width - userImageView.width - 30,
                                height: userImageView.height / 2.5)
        
        userLatestMessage.frame = CGRect(x: userImageView.right + 10,
                                         y: userName.bottom,
                                         width: contentView.width - userImageView.width - 30,
                                         height: userImageView.height / 1.4)
        
        userImageView.layer.cornerRadius = userImageView.width/2
        userImageView.clipsToBounds = true
    }
    
    func configure(with model: Conversation) {
        userName.text = model.name
        
        if model.latestMessage.text.prefix(23) == "https://firebasestorage" {
            userLatestMessage.font = .systemFont(ofSize: 36, weight: .light)
            userLatestMessage.text = "🌅"
            
        } else {
            userLatestMessage.text = model.latestMessage.text
        }
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to downoad url \(error.localizedDescription)")
            }
        }
    }
    
    
}
