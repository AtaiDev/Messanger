//
//  RegisterViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    private var isPasswordFieldSecure = true
    
    private let spinner = JGProgressHUD(style: .dark)
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person.circle")
        image.isUserInteractionEnabled = true
        image.contentMode = .scaleAspectFit
        image.tintColor = .lightGray
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.lightGray.cgColor
        image.clipsToBounds = true
        return image
    }()
    
    let firstName: UITextField = {
        let firstName = UITextField()
        firstName.placeholder = "First Name"
        firstName.returnKeyType = .continue
        firstName.autocapitalizationType = .none
        firstName.autocorrectionType = .no
        firstName.leftView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 10,
                                                  height: 0))
        firstName.leftViewMode = .always
        firstName.layer.cornerRadius = 12
        firstName.layer.borderWidth = 1
        firstName.layer.borderColor = UIColor.lightGray.cgColor
        firstName.layer.masksToBounds = true
        return firstName
    }()
    
    let lastName: UITextField = {
        let lastName = UITextField()
        lastName.placeholder = "Last Name"
        lastName.autocorrectionType = .no
        lastName.autocapitalizationType = .none
        lastName.returnKeyType = .continue
        lastName.layer.cornerRadius = 12
        lastName.layer.borderWidth = 1
        lastName.layer.borderColor = UIColor.lightGray.cgColor
        lastName.layer.masksToBounds = true
        lastName.leftView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 10,
                                                 height: 0))
        lastName.leftViewMode = .always
        return lastName
    }()
    
    let emailAddress: UITextField = {
        let email = UITextField()
        email.placeholder = "Email Address"
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.returnKeyType = .continue
        email.layer.cornerRadius = 12
        email.layer.masksToBounds = true
        email.layer.borderColor = UIColor.lightGray.cgColor
        email.layer.borderWidth = 1
        email.leftView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 10,
                                                  height: 0))
        email.leftViewMode = .always
        return email
    }()
    
    let passwordField: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.autocorrectionType = .no
        password.isSecureTextEntry = true
        password.returnKeyType = .done
        password.autocapitalizationType = .none
        password.layer.cornerRadius = 12
        password.layer.masksToBounds = true
        password.layer.borderColor = UIColor.lightGray.cgColor
        password.layer.borderWidth = 1
        password.leftViewMode = .always
        password.leftView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 10,
                                                 height: 0))
        let overlayButton = UIButton(type: .custom)
        let bookmarkImage = UIImage(systemName: "eye.slash")
        overlayButton.setImage(bookmarkImage, for: .normal)
        overlayButton.addTarget(self,
                                action: #selector(didEyeTapped(_ :)),
                                for: .touchUpInside)
        overlayButton.sizeToFit()
        password.rightView = overlayButton
        password.rightViewMode = .always
        return password
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register".uppercased(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = .green
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(registerDidTap), for: .touchUpInside)
        
        return button
    }()
    // user registration
    @objc func registerDidTap() {
        emailAddress.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        
        guard let email = emailAddress.text,
              let password = passwordField.text,
              let lastName = lastName.text,
              let firstName = firstName.text,
              !lastName.isEmpty,
              !password.isEmpty,
              !firstName.isEmpty,
              !email.isEmpty, password.count >= 6 else { return }
        
        spinner.show(in: view)
        
        DatabaseManager.shared.isUserExist(email: email) { [weak self] isUserExist in
            guard let strongSelf = self else { return }
            guard !isUserExist else  {
                // user exist
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss(animated: true)
                }
                strongSelf.alertUser(message: "Whoops",
                                     titleAlert: "Seems your email address exist already, try to LOGIN with email/password.")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error  in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss(animated: true)
                }
                guard authResult != nil, error == nil else {
                    strongSelf.alertUser(message: "Failed to create account, please try again.", titleAlert: "Account creation failed.")
                    return
                }
                let chatUser = ChatAppUser(
                    emailAddress: email,
                    firstName: firstName,
                    lastName: lastName
                )
                DatabaseManager.shared.addUser(appUser: chatUser, complition: { success in
                    if success {
                        // upload user
                        guard let image = strongSelf.profileImage.image,
                              let data = image.pngData() else {
                                  return
                              }
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: chatUser.profilePictureFileName) { result in
                            switch result {
                            case .success(let downloadedURL):
                                UserDefaults.standard.set(downloadedURL, forKey: "profile_picture_url")
                            case .failure(let error):
                                strongSelf.alertUser(message: error.localizedDescription, titleAlert: "Image URL fail.")
                            }
                        }
                    }
                    
                } )
                UserDefaults.standard.set(email, forKey: "email")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }

        }
    }
    // toogling the passwordField secure text entry
    @objc func didEyeTapped(_ sender : UIButton) {
        isPasswordFieldSecure.toggle()
        passwordField.isSecureTextEntry.toggle()
        
        if !isPasswordFieldSecure { sender.setImage(UIImage(systemName: "eye"), for: .normal) }
        else { sender.setImage(UIImage(systemName: "eye.slash"), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addsubViews()
        assignDeligates()
        addguestures()
        
    }
    func assignDeligates() {
        emailAddress.delegate = self
        passwordField.delegate = self
        firstName.delegate = self
        lastName.delegate = self
    }
    //guestures
    private func addguestures() {
        let guesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.addGestureRecognizer(guesture)
    }
        // profile tap
    @objc func profileImageTapped() {
        self.presentActionSheet()
    }
    
    private func addsubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(profileImage)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(emailAddress)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 4
        
        profileImage.frame = CGRect(x: (scrollView.width - size) / 2,
                                    y:  10, //self.navigationController?.navigationBar.frame.size.height ??
                                    width:  size,
                                    height: size)
        profileImage.layer.cornerRadius = profileImage.width/2
        
        firstName.frame = CGRect(x: 20,
                                 y: profileImage.bottom + 20,
                                 width: scrollView.width - 40,
                                 height: 52)
        
        lastName.frame = CGRect(x: 20,
                                y: firstName.bottom + 10,
                                width: firstName.width,
                                height: 52)
        
        emailAddress.frame = CGRect(x: 20,
                                    y: lastName.bottom  + 10,
                                    width: firstName.width,
                                    height: 52)
        
        passwordField.frame = CGRect(x: 20,
                                     y: emailAddress.bottom  + 10,
                                     width: firstName.width,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 20,
                                     y: passwordField.bottom  + 10,
                                     width: firstName.width,
                                     height: 52)
    }
    
    func alertUser(message: String, titleAlert: String) {
        let alert = UIAlertController(title: titleAlert, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated:  true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstName:
            lastName.becomeFirstResponder()
        case lastName:
            emailAddress.becomeFirstResponder()
        case emailAddress:
            passwordField.becomeFirstResponder()
        case passwordField:
            registerDidTap()
        default:
            print("let's see for now")
        }
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
      
    func presentActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Photo.",
                                            message: "Which of the following's would like to use?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cencel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self]_ in
            self?.cameraAction()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.photoGalaryAction()
        }))
        
        present(actionSheet, animated:  true)
    }
    
    func cameraAction() {
        let cameraController = UIImagePickerController()
        cameraController.delegate = self
        cameraController.allowsEditing = true
        cameraController.sourceType = .camera
        present(cameraController, animated: true)
    }
    
    func photoGalaryAction() {
        let photoController = UIImagePickerController()
        photoController.delegate = self
        photoController.allowsEditing = true
        photoController.sourceType = .photoLibrary
        present(photoController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profileImage.image = selectedImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
