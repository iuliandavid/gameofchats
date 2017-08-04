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
    
    var user: AppUser? {
        didSet {
            navigationItem.title = user?.name
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
        
        setupInputComponents()
        collectionView?.backgroundColor = .white
    }
    
    
    fileprivate func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
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
}

extension ChatLogController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
