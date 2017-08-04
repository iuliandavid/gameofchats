//
//  UserCell.swift
//  gameofchats
//
//  Created by iulian david on 8/4/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    
    
    var message: Message? {
        didSet {
            self.detailTextLabel?.text = message?.text
            
            setupProfileImage()
            self.timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(message!.timestamp!)))
            self.timeLabel.isHidden = false
        }
    }
    
    fileprivate func setupProfileImage() {
        
        let currentPartnerID: String?
        if message?.fromId == Auth.auth().currentUser?.uid {
            currentPartnerID = message?.toId
        } else {
            currentPartnerID = message?.fromId
        }
        
        if let id = currentPartnerID {
            DBConstants.getDB(reference: DBConstants.DBReferenceUsers).child(id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                if let snapshotValue = snapshot.value as? Dictionary<String, String> {
                    guard let profileImageURL = snapshotValue["profileImageUrl"] else {
                        return
                    }
                    self.textLabel?.text = snapshotValue["name"]
                    self.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
                    
                    
                }
            }, withCancel: nil)
        }
    }
    
    var user: AppUser? {
        didSet {
            self.textLabel?.text = user?.name
            self.detailTextLabel?.text = user?.email
            if let profileImageURL = user?.imageURL {
                self.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
                
            }
            self.timeLabel.isHidden = true
        }
    }
    
    static let imageSize: CGFloat = 48
    //the image is not showing
    // we need to set the labels x position
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.layer.cornerRadius = UserCell.imageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        //ios 9 constraints
        // nedd x, y, width and height constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: UserCell.imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: UserCell.imageSize).isActive = true
        
        //x, y, w, h anchors for time label
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
