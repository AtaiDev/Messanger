//
//  NewConversationViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFatched = false
    
    public var complition: (([String : String]) -> (Void))?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for User.."
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let emptyConverstionLable : UILabel = {
        let lable = UILabel()
        lable.isHidden = true
        lable.font = .systemFont(ofSize: 21, weight: .thin)
        lable.textColor = .darkGray
        lable.textAlignment = .center
        lable.text = "Converstion list empty."
        return lable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        setupSearchBar()
        setupTableView()
 
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
        emptyConverstionLable.frame = CGRect(x: (view.width - 200) / 2,
                                             y: (view.height-60) / 2,
                                             width: 200,
                                             height: 60)
    }
    
    // MARK: - METHODS DOWN BELOW
    @objc func dismissTapped() {
        dismiss(animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func addSubViews() {
        view.addSubview(tableView)
        view.addSubview(emptyConverstionLable)
       
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissTapped))
        searchBar.becomeFirstResponder()

    }

}
// MARK: - ECTENSIONS DOWN BELOW
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell : UITableViewCell = {
             guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                 return UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
             }
             cell.textLabel?.textColor = .darkGray
             cell.textLabel?.font = .systemFont(ofSize: 21, weight: .light)
             cell.textLabel?.text = results[indexPath.row]["name"]
             cell.accessoryType = .disclosureIndicator
             
            return cell
        }()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUser = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.complition?(targetUser)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let querySearch = searchBar.text, !querySearch.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        self.spinner.show(in: view)
        self.searchUsers(query: querySearch)
    }
    
    func searchUsers(query: String) {
        if hasFatched {
            filterUsers(with: query)
        }
        else {
            DatabaseManager.shared.fetchAllUsers { [weak self] result in
                switch result {
                case .success(let users):
                    self?.hasFatched = true
                    self?.users = users
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("error accured: \(error)")
                }
            }
        }
        searchBar.resignFirstResponder()
    }
    
    func filterUsers(with term: String) {
        guard hasFatched  else {
            return
        }
        DispatchQueue.main.async {
            self.spinner.dismiss(animated: true)
        }
        
        let results: [[String: String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        self.results = results
        updateUI()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("search cancel clicked")
        dismissTapped()
    }
    
    private func updateUI() {
        if results.isEmpty {
            self.emptyConverstionLable.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.emptyConverstionLable.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
