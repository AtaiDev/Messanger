//
//  NewConversationViewController.swift
//  Messanger
//
//  Created by admin on 2/1/22.
//

import UIKit

class NewConversationViewController: UIViewController {
 
    private var searchResults = [String]()
    
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
        lable.isHidden = false
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
    private func configureVisibilityEmptyState() {
        tableView.isHidden.toggle()
        emptyConverstionLable.isHidden.toggle()
    }
    
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
             cell.textLabel?.text = searchResults[indexPath.row]
             cell.accessoryType = .disclosureIndicator
             
            return cell
        }()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search clicked")
        searchBar.resignFirstResponder()
        searchResults = ["Aliman Jojo", "Delphin Jr", "TimerLike dude"]
        tableView.reloadData()
        configureVisibilityEmptyState()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("search cancel clicked")
        dismissTapped()
        configureVisibilityEmptyState()
    }
}
