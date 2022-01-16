//
//  ProfileViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    let data = ["Log Out"]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.register(ProfileHeaderTableView.self,
                           forHeaderFooterViewReuseIdentifier: ProfileHeaderTableView.profileIdentifier)
        tableView.reloadData()
    }
    
    private func getProfilePicPath() ->  String?  {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let imageFileName = DatabaseManager.safeEmail(emailAddress: email)  + "_profile_picture.png"
        let path = "images/"+imageFileName
        print("path: \(path)")
        return path
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { data,  _, error in
            guard let data = data, error == nil else {
                return
            }
            let image = UIImage(data: data)
          
            DispatchQueue.main.async {
                imageView.image = image
            }
            
        }.resume()
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.textColor = .red
        cell.textLabel?.font = .boldSystemFont(ofSize: 20)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let profileHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileHeaderTableView.profileIdentifier) as? ProfileHeaderTableView else {
            return UITableViewCell()
        }
        guard let profilePicPath = getProfilePicPath() else { return  nil }
        StorageManager.shared.downloadURL(for: profilePicPath ) { [weak self] results in
            switch results {
            case .success(let url):
                self?.downloadImage(imageView:  profileHeader.image, url: url)
            case .failure(let error):
                print("failed error: \(error.localizedDescription)")
            }
        }
        profileHeader.title.text = UserDefaults.standard.string(forKey: "name_show_profile")
        return profileHeader
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        actionSheetAlert()
    }
    
    func actionSheetAlert() {
        let actionSheet = UIAlertController(title: "Logout".capitalized,
                                            message: "Would you like to logout?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Logout",
                                            style: .destructive,
                                            handler: { [weak self]  _ in
            guard let strongSelf = self else { return }
            do {
                try Auth.auth().signOut()
                strongSelf.facebookLogout()
                
                strongSelf.navigatToLoginView()
            } catch {
                print("Failed on singing out the user")
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cencel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    fileprivate func navigatToLoginView() {
        let loginController = LoginViewController()
        let nav = UINavigationController(rootViewController: loginController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    fileprivate func facebookLogout() {
        let loginManager = LoginManager()
        loginManager.logOut()
        AccessToken.current = nil
    }

}
