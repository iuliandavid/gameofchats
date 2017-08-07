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
    var messages: [Message] = []
    var messagesDictionary: [String: Message] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: Tables.messagesCellIdentifier)
        
        
    }
    
    fileprivate func fetchMessage(with messageId : String) {
        let messagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceMessages).child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.toId = dictionary["toId"] as? String
                message.timestamp = dictionary["timestamp"] as? Int
                self.outputMessage(message)
                
                self.attemptReloadTable()
            }
        }, withCancel: nil)
    }
    
    func observeUserMessages() {
        
        guard let id = userUID else {
            return
        }
        let ref = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(id)
        ref.observe(.childAdded, with: { (snapshot) in
            let partnerId = snapshot.key
            let refPartnerID = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(id).child(partnerId)
            refPartnerID.queryOrdered(byChild: "timestamp").queryLimited(toLast: 1).observe(.childAdded, with: {
                userMessageSnapshot in
                let messageId = userMessageSnapshot.key
                self.fetchMessage(with: messageId)
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    fileprivate func attemptReloadTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort { (message1, message2) -> Bool in
            return message1.timestamp! > message2.timestamp!
        }
        configureTableView()
        DispatchQueue.main.async(execute: {
            print("Reloaded the table")
            self.tableView.reloadData()
        })
    }
    
    fileprivate func getCurrentUser(_ uid: String) {
        AppUser.getAppUser(for: uid) { (appUser) in
            self.user = appUser
            self.setUpNavigationBar()
        }
        
    }
    
    fileprivate func setUpNavigationBar() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        guard let user = user, let profileImageURL = user.imageURL else {
            return
        }
        
        profileImageView.loadImageUsingCache(withURLString: profileImageURL)
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        let label = UILabel()
        label.text = user.name
        containerView.addSubview(label)
        containerView.addSubview(profileImageView)
        //        containerView.setTitle(user.name, for: .normal)
        
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
        
        self.navigationItem.titleView = titleView
        //        //???
        //        titleView.isUserInteractionEnabled = true
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showChatController))
        //        tapGesture.numberOfTapsRequired = 1;
        //        self.navigationItem.titleView?.addGestureRecognizer(tapGesture)
        //        navigationItem.titleView?.isUserInteractionEnabled = true
        
        
    }
    
    func checkIfUserIsLoggedIn() {
        //user is not logged in
        guard let uid = Auth.auth().currentUser?.uid else {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return
        }
        self.userUID = uid
        guard let _ = user else {
            getCurrentUser(uid)
            return
        }
        
        
    }
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print(error.localizedDescription)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    func showChatController(for user: AppUser) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    fileprivate func outputMessage(_ message: Message) {
        let id = message.chatPartnerId()
        messagesDictionary[id!] = message
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120.0
    }
    
    
}

//MARK - Table DataSource
extension MessageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Tables.messagesCellIdentifier, for: indexPath)
            as? UserCell  else {
                return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        AppUser.getAppUser(for: chatPartnerId) { (appUser) in
            self.showChatController(for: appUser)
        }
        
        
    }
}




