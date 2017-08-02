//
//  UIIMageView+extensions.swift
//  gameofchats
//
//  Created by iulian david on 8/2/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit

// a cache for downloaded images
let imageCache = NSCache<NSString, UIImage>()


extension UIImageView {
    func loadImageUsingCache(withURLString urlString: String) {
        
        self.image = nil
        
        // we have to convert it to NSString since NSCache does not support String
        let nsStringURL = NSString(string: urlString)
        
        // search first in cache
        if let image = imageCache.object(forKey: nsStringURL) {
            self.image = image
            return
        }
        
        // if not found search in Firebase
        FirebaseAPI.getImageFromFirebase(profileImageURL: urlString, completion: { (image) in
            if let image = image {
                imageCache.setObject(image, forKey:  nsStringURL )
                self.image = image
            }
        })
    }
}

