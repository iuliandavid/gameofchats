//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by iulian david on 8/4/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit

enum Orientation {
    case right
    case left
}
class ChatMessageCell: UICollectionViewCell {
    
    static let blueColor: UIColor = UIColor(r: 0, g: 137, b: 249)
    static let grayColor: UIColor = UIColor(r: 240, g: 240, b: 240)
    
    var message: Message? {
        didSet {
            updateCell()
        }
    }
    
    var profileImageURL: String? {
        didSet {
            profileImageView.loadImageUsingCache(withURLString: profileImageURL!)
        }
    }
    var orientation: Orientation? {
        didSet {
            if orientation == .right {
                bubbleViewLeftAnchor?.isActive = false
                bubbleViewRightAnchor?.isActive = true
                profileImageView.isHidden = true
            } else {
                bubbleViewLeftAnchor?.isActive = true
                bubbleViewRightAnchor?.isActive = false
                profileImageView.isHidden = false
            }
        }
    }
    let chatText : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .clear
        return textView
    }()
    
    let bubbleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = blueColor
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "tyrion")
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bubbleView)
        self.addSubview(chatText)
        self.addSubview(profileImageView)
        
        // need x, y, width and height constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // need x, y, width and height constraints
        //        orientation = .right
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewRightAnchor =
            bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        
        // need x, y, width and height constraints
        chatText.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        chatText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        chatText.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        chatText.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateCell() {
        chatText.text = message?.text
//        chatText.sizeToFit()
    }
}
