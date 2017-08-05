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
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
