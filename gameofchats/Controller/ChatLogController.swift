//
//  ChatLogController.swift
//  gameofchats
//
//  Created by iulian david on 8/2/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    var messages = [Message]()
    
    var user: AppUser? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: ChatCollection.chatCellIdentifier)
        collectionView?.alwaysBounceVertical = true
        //padding from top
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        setupInputComponents()
    }
    
    
    fileprivate func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // x, y, w, h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add textfield
        
        // add button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(inputTextField)
        containerView.addSubview(sendButton)
        
        // x, y, w, h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -80).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // x, y, w, h
        sendButton.leftAnchor.constraint(equalTo: inputTextField.rightAnchor, constant: 2 ).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -2).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        // x, y, w, h
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
    }
    
    @objc func handleSend() {
        guard let message = inputTextField.text else {
            return
        }
        
        let ref = DBConstants.getDB(reference: DBConstants.DBReferenceMessages)
        let childRef = ref.childByAutoId()
        guard let toId = user?.uid else { return }
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        let values = ["text": message, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            let messagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(fromId)
            let pertnermessagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(toId)
            let messageID = childRef.key
            messagesRef.updateChildValues([messageID : 1])
            pertnermessagesRef.updateChildValues([messageID : 1])
        }
        
        inputTextField.text = ""
    }
    
    func observeMessages(){
        guard let uid = user?.uid else { return }
        guard let authId = Auth.auth().currentUser?.uid else { return }
        let ref = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(authId)
        
        ref.observe(.childAdded, with: { (userMessageSnapshot) in
            let mesageID = userMessageSnapshot.key
            let messagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceMessages).child(mesageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let message = Message()
                    message.fromId = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.toId = dictionary["toId"] as? String
                    message.timestamp = dictionary["timestamp"] as? Int
                    if message.chatPartnerId() == uid {
                        self.outputMessage(message)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    // MARK - Collection Data Source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCollection.chatCellIdentifier, for: indexPath) as? ChatMessageCell else {
            fatalError()
        }
        let message = messages[indexPath.item]
        cell.message = message
        
        let estimatedCellSize = estimateFrameForText(text: message.text!)
        cell.bubbleWidthAnchor?.constant = estimatedCellSize.width + 32
        cell.bubbleView.layer.cornerRadius = 16
        cell.bubbleView.layer.masksToBounds = true
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func outputMessage(_ message: Message) {
        self.messages.append(message)

        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        
    }
    
    
}

extension ChatLogController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}


extension ChatLogController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get estimated height
        let message = messages[indexPath.item]
        if let textMessage = message.text {
            height = estimateFrameForText(text: textMessage).height + 30
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    //reset anchors based on orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: 200, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
}
