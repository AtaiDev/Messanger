//
//  ViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.
//
import FirebaseAuth
import UIKit

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private var  user = [[String: String]]()
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.reusibleID)
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(composeTapped))
        addsubviews()
        setupTableVeiw()
        startListeningForConversations()
    }
    
    private func startListeningForConversations() {
        
        guard let userEmail = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: userEmail)
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to load data \(error.localizedDescription)")
            }
        }
    }
    
    private func addsubviews() {
        view.addSubview(tableView)
    }
    
    private func setupTableVeiw() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userAuth()
        
    }
    
    func userAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    @objc private func composeTapped() {
        let vc = NewConversationViewController()
        vc.complition = { [weak self] result in
            self?.tableView.reloadData()
            self?.createNewConversation(result: result)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    func createNewConversation(result: [String: String]) {
        guard let name = result["name"],
              let other_user_email = result["email"] else {
                  return
              }
        let vc = ChatViewController(with: other_user_email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let model = conversations[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.reusibleID) as? ConversationTableViewCell else {
            return UITableViewCell()
        }

        if  !conversations.isEmpty {
            tableView.isHidden = false
        }
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userEmail = conversations[indexPath.row].otherUserEmail
        let name = conversations[indexPath.row].name
        let vc = ChatViewController(with: userEmail, id: conversations[indexPath.row].id)
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
