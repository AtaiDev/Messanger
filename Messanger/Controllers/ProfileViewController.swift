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
