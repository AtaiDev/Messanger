//
//  PhotoViewerViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.
//

import UIKit
import SDWebImage
class PhotoViewerViewController: UIViewController {
    private let url: URL?
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle:  nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .black
        self.title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        imageView.frame = view.bounds
    }

}
