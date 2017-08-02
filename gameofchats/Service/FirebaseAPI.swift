//
//  FirebaseAPI.swift
//  gameofchats
//
//  Created by iulian david on 8/1/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPI {
    
    public static func getImageFromFirebase(profileImageURL: String,completion:  @escaping (UIImage?) -> () ) {
        // Firebase default implementation
        Storage.storage().reference(forURL: profileImageURL).getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("Error downloading: \(error)")
                return
            }
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                completion(UIImage.init(data: data))
                
            }
            
            
            // ios implementation
            //        if let url = URL(string: profileImageURL) {
            
            //                        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
            //                            if let error = err {
            //                                print("Error downloading: \(error)")
            //                                return
            //                            }
            //                            guard let data = data else {
            //                                return
            //                            }
            //                            DispatchQueue.main.async {
            //                                cell.imageView?.image = UIImage.init(data: data)
            //                            }
            //                        }).resume()
            //                }
        }
    }
}

