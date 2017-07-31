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
    
    static func getDB(reference: String) -> DatabaseReference {
        return Database.database().reference().child(reference)
    }
}
