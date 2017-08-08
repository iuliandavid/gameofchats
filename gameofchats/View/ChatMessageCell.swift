//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by iulian david on 8/4/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import AVFoundation

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
        textView.isEditable = false
        return textView
    }()
    
    let bubbleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.activityIndicatorViewStyle = .whiteLarge
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    var chatLogController: ChatLogController?
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            //TODO
            return
        }
        guard let imageView = tapGesture.view as? UIImageView else {
            return
        }
        chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bubbleView)
        self.addSubview(profileImageView)
        self.addSubview(chatText)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
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
        
        // need x, y, width and height constraints
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        // need x, y, width and height constraints
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 32)
        playButton.heightAnchor.constraint(equalToConstant: 32)
        
        // need x, y, width and height constraints
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 32)
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 32)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateCell() {
        if let imageUrl = message?.imageUrl {
            self.messageImageView.loadImageUsingCache(withURLString: imageUrl)
            self.messageImageView.isHidden = false
            self.chatText.isHidden = true
        } else {
            self.messageImageView.isHidden = true
            self.chatText.isHidden = false
            chatText.text = message?.text
            
        }
    }
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc private func handlePlay() {
        if let videoUrl = message?.videoUrl ,let url = URL(string: videoUrl)  {
            player = AVPlayer(url: url)
            //to see anything it's needed to add an AVPlayerLayer
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    //Clean up cell when reusing
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
}
