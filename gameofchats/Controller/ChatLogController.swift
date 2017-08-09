//
//  ChatLogController.swift
//  gameofchats
//
//  Created by iulian david on 8/2/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController {
    
    var messages = [Message]()
    
    var user: AppUser? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: ChatCollection.chatCellIdentifier)
        collectionView?.alwaysBounceVertical = true
        //padding from top
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        //the collection scroll will follow the keyboard up and down selection
        collectionView?.keyboardDismissMode = .interactive
        
        setupNotificationObservers()
        
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            scrollToLastItem()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //stop playing
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    
    
    
    var containerHeightAnchor: NSLayoutConstraint?
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        guard let message = inputContainerView.inputTextField.text else {
            return
        }
        sendMessage(properties: ["text": message])
        inputContainerView.inputTextField.text = nil
    }
    
    func observeMessages(){
        guard let uid = user?.uid else { return }
        guard let authId = Auth.auth().currentUser?.uid else { return }
        let ref = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(authId).child(uid)
        
        ref.observe(.childAdded, with: { (userMessageSnapshot) in
            let mesageID = userMessageSnapshot.key
            Message.fetchMessage(with: mesageID, completion: { (message) in
                self.outputMessage(message)
            })
        }, withCancel: nil)
        
    }
    
    // MARK - Collection Data Source
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCollection.chatCellIdentifier, for: indexPath) as? ChatMessageCell else {
            fatalError()
        }
        let message = messages[indexPath.item]
        setupCell(message, cell)
        
        cell.message = message
        
        cell.chatLogController = self
        
        if let text = message.text {
            let estimatedCellSize = estimateFrameForText(text: text)
            cell.bubbleWidthAnchor?.constant = estimatedCellSize.width + 32
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    fileprivate func setupCell(_ message: Message, _ cell: ChatMessageCell) {
        if message.fromId == user?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
            cell.orientation = .left
            cell.chatText.textColor = .black
            cell.profileImageURL = user?.imageURL
        } else {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.orientation = .right
            cell.chatText.textColor = .white
            
        }
        if let _ = message.imageUrl {
            cell.bubbleView.backgroundColor = .clear
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func outputMessage(_ message: Message) {
        self.messages.append(message)
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.scrollToLastItem()
        }
        
    }
    
    func scrollToLastItem() {
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func sendMessage(properties: [String: Any]) {
        let ref = DBConstants.getDB(reference: DBConstants.DBReferenceMessages)
        let childRef = ref.childByAutoId()
        guard let toId = self.user?.uid else { return }
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        properties.forEach {values[$0] = $1}
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            let messagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(fromId).child(toId)
            let pertnermessagesRef = DBConstants.getDB(reference: DBConstants.DBReferenceUserMessages).child(toId).child(fromId)
            let messageID = childRef.key
            messagesRef.updateChildValues([messageID : 1])
            pertnermessagesRef.updateChildValues([messageID : 1])
        }
    }
    
    //Zooming
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get estimated height
        let message = messages[indexPath.item]
        let width = UIScreen.main.bounds.width
        if let textMessage = message.text {
            height = estimateFrameForText(text: textMessage).height + 30
        } else if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
            // h1/w1 = h2/w2
            // h1 = h2 / w2 * w1
            height = round(CGFloat(imageHeight) / CGFloat(imageWidth) * CGFloat(200))
        }
        
        return CGSize(width: width, height: height)
    }
    
    //reset anchors based on orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: 200, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
}

//MARK: KeyboardWillShow/Hide functionality
extension ChatLogController {
    //Implementing view aligning with keyboard by using inputAccessoryView
    //KeyboardWillShow/Hide equivalent
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return inputContainerView
    }
    
}


extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleUploadTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    fileprivate func handleVideoSelected(_ fileUrl: URL) {
        let fileName = "\(UUID.init().uuidString).mov"
        let refStorage = Storage.storage().reference().child(StorageConstants.messageVideos).child(fileName)
        let uploadTask = refStorage.putFile(from: fileUrl, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            if let videoUrl = (metadata?.downloadURL()?.absoluteString) {
                // 1 . create thumbnail
                if let thumbnailImage = self.getThumbnailImage(for: fileUrl) {
                    self.uploadToFirebase(usingImage: thumbnailImage, completion: { (imageUrl) in
                        let properties: [String : Any] = ["videoUrl": videoUrl, "imageUrl": imageUrl, "imageHeight": Int(thumbnailImage.size.height), "imageWidth": Int(thumbnailImage.size.width)]
                        self.sendMessage(properties: properties)
                    })
                    
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            guard let progress = snapshot.progress?.completedUnitCount else {
                return
            }
            self.navigationItem.title = String(describing: progress)
            
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
            
        }
    }
    
    private func getThumbnailImage(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageAssetGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
        let thumbnailCGImage = try imageAssetGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err.localizedDescription)
            return nil
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //video
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelected(videoUrl)
        } else {
            //image
            handleSelectedImage(info: info)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func handleSelectedImage(info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        // Take the image
        if let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage? {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            selectedImageFromPicker = originalImage
        }
        //        imageView.image = image
        if let selectedImage = selectedImageFromPicker {
            //save it
            uploadToFirebase(usingImage: selectedImage, completion: { (imageUrl) in
                self.sendMessage(withImageUrl: imageUrl, image: selectedImage)
                //put in cache
                self.saveImageToCache(image: selectedImage, url: imageUrl)
            })
            
            
        }
    }
    
    fileprivate func uploadToFirebase(usingImage image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let imagePath = UUID.init().uuidString
        let refStorage = Storage.storage().reference().child(StorageConstants.messageImages).child(imagePath)
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            refStorage.putData(imageData, metadata: nil, completion: { (metadata, err) in
                if err != nil {
                    print(err?.localizedDescription ?? "unknown")
                    return
                }
                if let messageImageUrl = (metadata?.downloadURL()?.absoluteString) {
                    completion(messageImageUrl)
                    
                }
            })
        }
        
    }
    
    fileprivate func sendMessage(withImageUrl url: String, image: UIImage) {
        sendMessage(properties: ["imageUrl": url, "imageHeight": Int(image.size.height), "imageWidth": Int(image.size.width)])
    }
    
    fileprivate func sendMessage(withVideoUrl url: String, video: UIImage) {
        sendMessage(properties: ["videoUrl": url])
    }
    
    
    fileprivate func saveImageToCache(image: UIImage, url: String) {
        imageCache.setObject(image, forKey:  NSString(string: url))
    }
}


//MARK: Zoom logic
extension ChatLogController {
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        // 1. Set the UIImageView's frame to image
        self.startingImageView = startingImageView
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        guard let image = startingImageView.image, let startingFrame = startingFrame else {
            return
        }
        let zoomingImageView = UIImageView(frame: startingFrame)
        zoomingImageView.image = image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutImage)))
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        blackBackgroundView = UIView(frame: keyWindow.frame)
        blackBackgroundView?.backgroundColor = .black
        blackBackgroundView?.alpha = 0
        blackBackgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnBackgroundTap)))
        keyWindow.addSubview(blackBackgroundView!)
        
        blackBackgroundView?.addSubview(zoomingImageView)
        startingImageView.isHidden = true
        //2. zoom the view into center
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.blackBackgroundView?.alpha = 1
            self.inputContainerView.alpha = 0
            
            //height calculated from formula : h1 / w1 = h2 / w2
            let height = startingFrame.height / startingFrame.width * keyWindow.frame.width
            
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
        }, completion: nil)
        
        
    }
    
    //Should the user tap the black background
    @objc private func handleZoomOutOnBackgroundTap(tapGesture: UITapGestureRecognizer) {
        //1. zoom out by setting the alphas
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            tapGesture.view?.alpha = 0
            self.inputContainerView.alpha = 1
        }, completion: nil)
    }
    
    @objc private func handleZoomOutImage(tapGesture: UITapGestureRecognizer) {
        // 1. get the reference of the view tapped
        guard let zoomOutImageView = tapGesture.view, let startingFrame = startingFrame else {
            return
        }
        //2.animate back to controller
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //put back the zoomimage to original imageView position
            zoomOutImageView.frame = startingFrame
            self.blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 1
            self.startingImageView?.isHidden = false
        }, completion: { (completed) in
            zoomOutImageView.removeFromSuperview()
            
        })
        
    }
}
