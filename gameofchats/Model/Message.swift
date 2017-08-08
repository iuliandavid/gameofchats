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
    var imageHeight: Int?
    var imageWidth: Int?
    var videoUrl: String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(from dictionary: [String: Any]) {
        super.init()
        imageUrl = dictionary["imageUrl"] as? String
        text = dictionary["text"] as? String
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        timestamp = dictionary["timestamp"] as? Int
        imageHeight = dictionary["imageHeight"] as? Int
        imageWidth = dictionary["imageWidth"] as? Int
        videoUrl = dictionary["videoUrl"] as? String
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
