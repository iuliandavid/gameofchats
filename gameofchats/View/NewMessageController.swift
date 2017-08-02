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
        DBConstants.getDB(reference: DBConstants.DBReferenceUsers).observe(.childAdded) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: String] {
                let user = AppUser()
                user.name = snapshotValue["name"]
                user.email = snapshotValue["email"]
                user.imageURL = snapshotValue["profileImageUrl"]
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
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
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageURL = user.imageURL {
           cell.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

class UserCell: UITableViewCell {
    static let imageSize: CGFloat = 48
    //the image is not showing
    // we need to set the labels x position
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.layer.cornerRadius = UserCell.imageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        
        //ios 9 constraints
        // nedd x, y, width and height constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: UserCell.imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: UserCell.imageSize).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
