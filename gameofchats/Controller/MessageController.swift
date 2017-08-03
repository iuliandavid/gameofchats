//
//  MessageController.swift
//  gameofchats
//
//  Created by iulian david on 7/30/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.layer.cornerRadius = 40 / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var user: AppUser?
    var userUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.titleView?.addSubview(profileImageView)
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkIfUserIsLoggedIn()
        
    }
    
    fileprivate func getCurrentUser(_ uid: String) {
        
        DBConstants.getDB(reference: DBConstants.DBReferenceUsers).child(uid).observeSingleEvent(of: .value, with: { [weak self]
            (snapshot) in
            if let snapshotValue = snapshot.value as? Dictionary<String, String> {
                guard let strongSelf = self else { return }
                strongSelf.user = AppUser()
                strongSelf.user?.name = snapshotValue["name"]
                strongSelf.user?.email = snapshotValue["email"]
                strongSelf.user?.imageURL = snapshotValue["profileImageUrl"]
                strongSelf.setUpNavigationBar()
            }
        })
    }
    
    fileprivate func setUpNavigationBar() {
        guard let user = user, let profileImageURL = user.imageURL else {
            return
        }
        profileImageView.loadImageUsingCache(withURLString: profileImageURL)
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTitleViewTap)))
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        let label = UILabel()
        label.text = user.name
        containerView.addSubview(label)
        containerView.addSubview(profileImageView)
        
        navigationItem.titleView = titleView
        
        
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
    }
    
    fileprivate func checkIfUserIsLoggedIn() {
        //user is not logged in
        guard let uid = Auth.auth().currentUser?.uid else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return
        }
        
        guard let user = user else {
            getCurrentUser(uid)
            return
        }
        self.navigationItem.title = user.name
        
    }
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print(error.localizedDescription)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    @objc func handleTitleViewTap() {
        let logChatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(logChatController, animated: true)
    }
    
    
}
