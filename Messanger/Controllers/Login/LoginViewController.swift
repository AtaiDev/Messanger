//
//  LoginViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.


import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD
import SwiftUI

class LoginViewController: UIViewController  {
    
    private let spinner  = JGProgressHUD(style: .dark)
    
    private let eyeImage: UIImageView = {
        let largeFont = UIFont.systemFont(ofSize: 60)
        let configuration = UIImage.SymbolConfiguration(font: largeFont)
        let image = UIImage(systemName: "eye.slash", withConfiguration: configuration)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .darkGray
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let email = UITextField()
        email.autocorrectionType = .no
        email.autocapitalizationType = .none
        email.returnKeyType = .continue
        email.layer.cornerRadius = 12
        email.layer.borderColor = UIColor.lightGray.cgColor
        email.layer.borderWidth = 1
        email.placeholder = "Email Address"
        email.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 10,
                                              height: 0))
        email.leftViewMode = .always
        return email
    }()
    
    private let passwordField: UITextField = {
        let password = UITextField()
        password.autocorrectionType = .no
        password.autocapitalizationType = .none
        password.returnKeyType = .done
        password.layer.cornerRadius = 12
        password.layer.borderColor = UIColor.lightGray.cgColor
        password.layer.borderWidth = 1
        password.placeholder = "Password"
        password.isSecureTextEntry = true
        password.leftView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 10,
                                                 height: 0))
        password.rightView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 40,
                                                  height: 0))
        password.rightViewMode = .always
        password.leftViewMode = .always
        return password
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .link
        return button
    }()
    
    private let loginFacebookButton: FBLoginButton = {
        let loginBtnFaceBook = FBLoginButton()
        loginBtnFaceBook.layer.cornerRadius = 12
        loginBtnFaceBook.layer.masksToBounds = true
        loginBtnFaceBook.permissions = ["public_profile", "email"]
        return loginBtnFaceBook
    }()
    
    private let loginGoogleButton: GIDSignInButton = {
        let loginGoogleButton = GIDSignInButton()
        loginGoogleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        return loginGoogleButton
    }()
    
    // MARK: now on, variables
    private var  isFieldSecure = true
    
    // MARK: now on functions
    @objc func eyeTapped() {
        isFieldSecure.toggle()
        
        if isFieldSecure {
            eyeImage.image = UIImage(systemName: "eye.slash")
            passwordField.isSecureTextEntry = true
        } else {
            eyeImage.image = UIImage(systemName: "eye")
            passwordField.isSecureTextEntry = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Log in"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        // subview handle
        
        addSubviews()
        gestureRecognizers()
        assignDeligates()
        
    }
    
    private func assignDeligates() {
        emailField.delegate = self
        passwordField.delegate = self
        loginFacebookButton.delegate = self
        
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoImage)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(loginFacebookButton)
        scrollView.addSubview(loginGoogleButton)
        // eye as subview
        passwordField.addSubview(eyeImage)
        
    }
    
    private func gestureRecognizers() {
        //password eye simbol
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(eyeTapped))
        eyeImage.isUserInteractionEnabled = true
        eyeImage.addGestureRecognizer(singleTap)
        // loginButton
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/2
        
        logoImage.frame = CGRect(
            x: (scrollView.width-size)/2,
            y: self.navigationController?.navigationBar.frame.size.height ?? 20,
            width: size,
            height: size)
        
        emailField.frame = CGRect(x: 10,
                                  y: logoImage.bottom + 20,
                                  width: scrollView.width - 20,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 10,
                                     y: emailField.bottom + 20,
                                     width: scrollView.width - 20,
                                     height: 52)
        
        eyeImage.frame = CGRect(x: (passwordField.right - 50 ),
                                y: (passwordField.height / 1.5) - (passwordField.height) / 2 ,
                                width: 35, // remember binary assingment
                                height: (passwordField.height / 1.7))
        
        loginButton.frame = CGRect(x: 10,
                                   y: passwordField.bottom + 20,
                                   width: scrollView.width - 20,
                                   height: 52)
        
        loginFacebookButton.frame = CGRect(x: 10,
                                           y: loginButton.bottom + 20,
                                           width: scrollView.width - 20,
                                           height: 42)
        
        loginGoogleButton.frame = CGRect(x: 10,
                                         y: loginFacebookButton.bottom + 20,
                                         width: scrollView.width - 20,
                                         height: 42)
        
    }
    
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
                  alertUserLoginError()
                  return
              }
        spinner.show(in: view)
        
        // MARK: - Firebase Log In down below
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            guard  authResult != nil, error == nil else {
                      self? .logingFailed()
                      return
                  }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getUserData(for: safeEmail) { result in
                switch result {
                case .success(let fullName):
                    UserDefaults.standard.setValue(fullName, forKey: "full_name")
                case .failure(_):
                    print("failed to save user name locally")
                }
            }
            UserDefaults.standard.setValue(email, forKey: "email")

            strongSelf.navigationController?.dismiss(animated: true)
        }
        
    }
    
    func logingFailed() {
        let loginFailedAlert = UIAlertController(title: "Login failed.",
                                                 message: "Please registered before you login or make sure your password or email are correct.",
                                                 preferredStyle: .alert)
        
        loginFailedAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(loginFailedAlert, animated: true)
    }
    
    func alertUserLoginError (message: String = "Provide all the informations to login",  shoudLogOut: Bool = false) {
        let alert = UIAlertController(title: "Login error.",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            if shoudLogOut {
                let loginManager = LoginManager()
                loginManager.logOut()
                AccessToken.current = nil
            }
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - checkAndInsertUser
    private func checkAndInsertUser(userModel: CheckAndInsertModel) {
        DatabaseManager.shared.isUserExist(email: userModel.email) { userExist in
            if !userExist {
                let chatUser = ChatAppUser(emailAddress: userModel.email,
                                           firstName: userModel.first_name,
                                           lastName: userModel.last_name)
                
                DatabaseManager.shared.addUser(appUser: chatUser) { success in
                    if success  {
                        // upload image
                        let fileName = chatUser.profilePictureFileName
                        URLSession.shared.dataTask(with: userModel.imageURL, completionHandler: { data, _, _ in
                            guard let data = data else {
                                return
                            }
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, complition: { result in
                                switch result {
                                case .success(let downloadURL):
                                    UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                case .failure(let error):
                                    self.alertUserLoginError(message: error.localizedDescription, shoudLogOut: false)
                                }
                            })
                        }).resume()
                    }
                    
                }
            }
        }
    }
    
    /// provide credentials to firebase singin
    private func firebseSigninCredential(credential: AuthCredential) {
        FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            guard  authResult != nil, error == nil else {
                if  error != nil {
                    strongSelf.alertUserLoginError(message: "An account already exists with the same email address but different sign-in credentials.", shoudLogOut: true)
                }
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Google singin
    @objc private func googleSignInTapped() {
        guard let clientID = FirebaseAuth.Auth.auth().app?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(
            with: config,
            presenting: self
        ) { [weak self] user, error in
            guard let strongSelf = self else {
                return
            }
            guard let userUnwrapped = user else { return }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken,
                let emailAddress = userUnwrapped.profile?.email,
                let first_name = userUnwrapped.profile?.givenName,
                let last_name = userUnwrapped.profile?.familyName
            else {
                return
            }
            
            UserDefaults.standard.setValue("\(first_name) \(last_name)", forKey: "full_name")
            UserDefaults.standard.setValue(emailAddress, forKey: "email")
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            if  ((userUnwrapped.profile?.hasImage) != nil) {
                guard let url = userUnwrapped.profile?.imageURL(withDimension: 200) else {
                    return
                }
                strongSelf.checkAndInsertUser(userModel: CheckAndInsertModel(email: emailAddress,
                                                                             first_name: first_name,
                                                                             last_name: last_name,
                                                                             imageURL: url
                                                                            ) )
            }
            strongSelf.firebseSigninCredential(credential: credential)
            
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}
// MARK: FACEBOOK login integration
extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("log out")
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("user failed to log  in with Facebook")
            return
        }
        
        let facebookRequest = FBSDKCoreKit.GraphRequest(graphPath: "me",
                                                        parameters: ["fields":
                                                                        "id, email, first_name, last_name, picture.type(large)"],
                                                        tokenString: token,
                                                        version: nil,
                                                        httpMethod: .get)
        
        facebookRequest.start { [weak self] _, result, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = result as? [String: Any] , error == nil else {
                print("Failed to graphRequest ")
                return
            }
            if let email = result["email"] as? String,
               let first_name = result["first_name"] as? String,
               let last_name = result["last_name"] as? String,
               let picture = result["picture"] as? [String: Any],
               let data = picture["data"] as? [String: Any],
               let pictureUrl = data["url"] as? URL {
                
                // check and insert user to Database
                strongSelf.checkAndInsertUser(userModel: CheckAndInsertModel(email: email,
                                                                             first_name: first_name,
                                                                             last_name: last_name,
                                                                             imageURL: pictureUrl))
                UserDefaults.standard.setValue("\(first_name) \(last_name)", forKey: "full_name")
                UserDefaults.standard.setValue(email, forKey: "email")
            }
        }
       
        let credantial = FacebookAuthProvider.credential(withAccessToken: token)
        firebseSigninCredential(credential: credantial)
        
    }
}

struct CheckAndInsertModel {
    var email: String,
        first_name: String,
        last_name: String,
        imageURL: URL
}
