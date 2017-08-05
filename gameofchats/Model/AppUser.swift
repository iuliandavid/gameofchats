//
//  User.swift
//  gameofchats
//
//  Created by iulian david on 7/31/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit

class AppUser: NSObject {
    
    var name: String?
    var email: String?
    var imageURL : String?
    var uid : String?
    
    static func getAppUser(for id: String, completion: @escaping (AppUser) -> ()) {
        DBConstants.getDB(reference: DBConstants.DBReferenceUsers).child(id).observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshotValue = snapshot.value as? Dictionary<String, String> {
                let user = AppUser()
                user.name = snapshotValue["name"]
                user.email = snapshotValue["email"]
                user.imageURL = snapshotValue["profileImageUrl"]
                user.uid = id
                completion(user)
            }
        })
    }
}
