//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by iulian david on 8/4/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    static let imageSize: CGFloat = 48
    
    var message: Message? {
        didSet {
            updateCell()
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
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        return view
    }()
    

    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bubbleView)
        self.addSubview(chatText)
        
        // need x, y, width and height constraints
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
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
        chatText.sizeToFit()
    }
}
