//
//  ProfileHeaderTableView.swift
//  Messanger
//
//  Created by admin on 14/1/22.
//

import UIKit

class ProfileHeaderTableView: UITableViewHeaderFooterView {
    
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
        imageView.layer.cornerRadius = 100 / 2
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1.2
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configureContents()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(image)
        contentView.addSubview(title)

        // constrain leading of imageView to be 15-pts from the leading of the contentView
//        let imgViewLeading = image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)

        // constrain width of imageView to 42-pts
        let imgViewWidth = image.widthAnchor.constraint(equalToConstant: 100)
        
        // constrain height of imageView to be equal to width of imageView
        let imgViewHeight = image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 1.0)

        // center imageView vertically
//        let imgViewCenterY = image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0.0)
        // center imageView horizontally
        let imageViewCenterX = image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0)

        // top and bottom constraints for the imageView also need to be set,
        // otherwise the image will exceed the height of the cell when there
        // is not enough text to wrap and expand the height of the label

        // constrain top of imageView to be *at least* 4-pts from the top of the cell
        let imgViewTop = image.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 0)

        // constrain bottom of imageView to be *at least* 4-pts from the bottom of the cell
        let imgViewBottom = image.topAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)

        // constrain top of the label to be *at least* 4-pts from the top of the cell
//        let top = title.topAnchor.constraint(equalTo: image.topAnchor, constant: 4)

        // if you want the text in the label vertically centered in the cell
        let bottom = title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)

        // if you want the text in the label top-aligned in the cell
//         let bottom = customLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)

        // constrain leading of the label to be 5-pts from the trailing of the image
        let leadingFromImage = title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)

        // constrain the trailing of the label to the trailing of the contentView
        let trailing = title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        NSLayoutConstraint.activate([
//            top,
            bottom,
            leadingFromImage,
            trailing,
//            imgViewCenterY,
            imageViewCenterX,
            imgViewWidth,
            imgViewHeight,
            imgViewTop,
//            imgViewBottom
            ])
    }
    
    
}
