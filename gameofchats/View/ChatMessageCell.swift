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
        textView.backgroundColor = .clear
        return textView
    }()
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .blue
        self.addSubview(chatText)
        // nedd x, y, width and height constraints
        chatText.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        chatText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        chatText.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
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
