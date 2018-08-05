//
//  SettingTableViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/28.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//
import UIKit
import SDWebImage
import ProgressHUD
import ImagePicker
protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerImageView:UIImageView!
    
    var delegate : SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        usernameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func fetchCurrentUser(){
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            if let profileUrl = URL(string:user.profileImageUrl!){
                self.profileImageView.sd_setImage(with: profileUrl)
            }
            if let headerUrl = URL(string: user.headerImageUrl!){
                self.headerImageView.sd_setImage(with: headerUrl)
            }
        }
    }
    
    @IBAction func saveBtn_touchUpInside(_ sender: Any) {
        if let profileImage = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImage, 0.1), let headerImage = self.headerImageView.image, let imageData2 = UIImageJPEGRepresentation(headerImage, 0.1){
            ProgressHUD.show("Waiting...")
            AuthService.updateUserInfo(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, imageData2:imageData2,onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfo()
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            }
        }
        
    }
    
    @IBAction func logOutBtn_touchUpInside(_ sender: Any) {
        AuthService.logOut(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errormessage) in
            ProgressHUD.showError(errormessage)
        }
    }
    
    @IBAction func changeProfileImageBtn_touchUpInside(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func changeHeaderImageBtn_touchUpInside(_sender:Any){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
        
    }
}



extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            headerImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension SettingTableViewController:ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
        profileImageView.image = image
        dismiss(animated: true,completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension SettingTableViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

