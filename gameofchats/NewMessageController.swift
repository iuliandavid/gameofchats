//
//  NewMessageController.swift
//  gameofchats
//
//  Created by iulian david on 7/31/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users: [AppUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUser()
    }
    
    func fetchUser() {
        DBConstants.getDB(reference: DBConstants.DBReferenceUsers).observe(.childAdded, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: String] {
                let user = AppUser()
                user.name = snapshotValue["name"]
                user.email = snapshotValue["email"]
                user.imageURL = snapshotValue["profileImageUrl"]
                user.uid = snapshot.key
                self.users.append(user)
                self.tableView.reloadData()
            }
        }, withCancel: { (err) in
            print(err)
        })
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell else {
            fatalError()
        }
        
        let user = users[indexPath.row]
        cell.user = user
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    var messageController : MessageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatController(for: user)
        }
    }
}

