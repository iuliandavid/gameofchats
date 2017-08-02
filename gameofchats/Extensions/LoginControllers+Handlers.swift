//
//  LoginControllers+Handlers.swift
//  gameofchats
//
//  Created by iulian david on 8/1/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit
import Firebase

extension LoginController {
    
    //MARK - Actions
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
        
    }
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        
        // change height of inputContainerView
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = true
        nameTextFieldHeightAnchor?.isActive = true
        
        //inputsContainerViewHeightAnchor?.isActive = true
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func saveUserToDB(uid: String, userValue : [String: Any]) {
        // persist the authenticated user to "goc_users" db
        let messagesDB = DBConstants.getDB(reference: DBConstants.DBReferenceUsers).child(uid)
        
        messagesDB.setValue(userValue, withCompletionBlock: { (err, ref) in
            if err != nil {
                let alertController = UIAlertController(title: "Error", message: err!.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: {
                    self.passwordTextField.text = ""
                })
                return
            }
            
            print("User saved")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            let alertController = UIAlertController(title: "Error", message: "Invalid Email or Password!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: {
                self.passwordTextField.text = ""
            })
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.passwordTextField.text = ""
                })
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                guard let uid = user?.uid else {
                    return
                }
                //persist image to storage
                let imagePath = "\(uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                let storage = Storage.storage().reference().child("profile_images").child(imagePath)
                if let imageData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.8) {
                    storage.putData(imageData, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err?.localizedDescription ?? "unknowen")
                            return
                        }
                        if let profileImageUrl = (metadata?.downloadURL()?.absoluteString) {
                        let userValue = ["email" : email, "name" : name, "profileImageUrl" : profileImageUrl] as [String : Any]
                        self.saveUserToDB(uid: uid, userValue: userValue)
                        }
                    })
                }
                
                
                
                
            }
        }
    }
    
    private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            let alertController = UIAlertController(title: "Error", message: "Invalid Email or Password!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: {
                self.passwordTextField.text = ""
            })
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if err != nil {
                let alertController = UIAlertController(title: "Error", message: err!.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: {
                    self.passwordTextField.text = ""
                })
                return
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage? {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)

    }
}
