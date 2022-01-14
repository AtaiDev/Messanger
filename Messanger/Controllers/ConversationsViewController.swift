//
//  ViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.
//
import FirebaseAuth
import UIKit

class ConversationsViewController: UIViewController {
   
    private var  user = ["Temirlan", "Argen",  "Tikiki"]
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        fetchConversations()
    }
    
    private func fetchConversations(){
        
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
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }

    
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            }
            return cell
        }()
        if  !user.isEmpty {
            tableView.isHidden = false
        }
        cell.textLabel?.textAlignment = .left
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 21, weight: .heavy)
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = user[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = user[indexPath.row]
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
