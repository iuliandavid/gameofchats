//
//  Constants.swift
//  gameofchats
//
//  Created by iulian david on 7/31/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import Foundation
import Firebase



struct DBConstants {
    static let DBReferenceUsers = "goc_users"
    static let DBReferenceMessages = "goc_messages"
    static let DBReferenceUserMessages = "goc_user_messages"
    
    static func getDB(reference: String) -> DatabaseReference {
        return Database.database().reference().child(reference)
    }
}

struct Tables {
    static let messagesCellIdentifier = "messageCell"
}

struct ChatCollection {
    static let chatCellIdentifier = "chatCell"
}

let dateFormatter : DateFormatter = {
    let formater = DateFormatter()
    formater.dateFormat = "HH:mm:ss"
    return formater
}()

struct StorageConstants {
    static let profileImages = "profile_images"
    static let messageImages = "message_images"
    static let messageVideos = "message_videos"
}
