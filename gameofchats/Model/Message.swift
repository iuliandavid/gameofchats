//
//  Message.swift
//  gameofchats
//
//  Created by iulian david on 8/3/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: Int?
    var imageUrl: String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(from dictionary: [String: Any]) {
        super.init()
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        } else {
            self.text = dictionary["text"] as? String
        }
        self.fromId = dictionary["fromId"] as? String
        
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? Int
    }
    
    static func fetchMessage(with messageId : String, completion: @escaping (Message) -> Void) {
        let messagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceMessages).child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                completion(Message(from: dictionary))
            }
        }, withCancel: nil)
    }
}
