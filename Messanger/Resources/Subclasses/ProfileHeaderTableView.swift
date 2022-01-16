//
//  ProfileHeaderTableView.swift
//  Messanger
//
//  Created by admin on 14/1/22.
//

import UIKit

class ProfileHeaderTableView: UITableViewHeaderFooterView {
    static let profileIdentifier = "ProfileHeaderTableView"
    var title: UILabel = {
        let userName = UILabel()
        userName.textAlignment = .center
        userName.font = .systemFont(ofSize: 21, weight: .heavy)
        userName.textColor = .black
        return userName
    }()
    
    var image: UIImageView  = {
        let imageView =   UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func addSubViews() {
        contentView.addSubview(image)
        contentView.addSubview(title)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        image.frame = CGRect(x: (contentView.frame.size.width - 100) / 2,
                             y: 0,
                             width: 100,
                             height: 100
        )
        
        title.frame = CGRect(x: 10,
                             y: image.bottom,
                             width: contentView.width - 20,
                             height: 60)
        
        image.layer.cornerRadius = image.width / 2
        
    }
    
}
