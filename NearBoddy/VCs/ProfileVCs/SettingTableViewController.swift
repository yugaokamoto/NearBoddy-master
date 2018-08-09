//
//  SettingTableViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/28.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//
import UIKit
import SDWebImage
import Firebase
import ProgressHUD
import ImagePicker
protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailLabel:UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerImageView:UIImageView!
    
    var delegate : SettingTableViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        usernameTextField.delegate = self
       
    }
    
    func fetchCurrentUser(){
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailLabel.text = user.email
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
            ProgressHUD.show("変更を保存しています...")
            AuthService.updateUserInfo(username: usernameTextField.text!, email: emailLabel.text!, imageData: imageData, imageData2:imageData2,onSuccess: {
                ProgressHUD.showSuccess("変更を保存しました！")
                self.delegate?.updateUserInfo()
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            }
        }
        
    }
    
    @IBAction func logOutBtn_touchUpInside(_ sender: Any) {
        
         let alertViewConroller = UIAlertController(title: "本当にログアウトしますか？", message: "再度ログインする場合はログイン画面で再度メールアドレスとパスワードを入力してください。", preferredStyle: .actionSheet)
        let Yes = UIAlertAction(title: "はい", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            AuthService.logOut(onSuccess: {
                let storyboard = UIStoryboard(name: "Start", bundle: nil)
                let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                self.present(signInVC, animated: true, completion: nil)
            }) { (errormessage) in
                ProgressHUD.showError(errormessage)
            }
        })
        
        let No = UIAlertAction(title: "いいえ", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            
        })
        
        alertViewConroller.addAction(Yes)
        alertViewConroller.addAction(No)
        
         present(alertViewConroller, animated: true, completion: nil)
    }
    
    @IBAction func changeProfileImageBtn_touchUpInside(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func changeHeaderImageBtn_touchUpInside(_ sender:Any){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func sendChangePasswordEmail(_ sender:Any){
        
           let alertViewConroller = UIAlertController(title: "パスワードを変更しますか？", message: "パスワードを変更するために現在のアドレス宛にパスワードリセットメールを送ります。ご確認後、再度ログイン画面からログインしてください。", preferredStyle: .actionSheet)
        
        let Yes = UIAlertAction(title: "変更確認メールを送る", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            
            ProgressHUD.show("メールを送信しています...")
            AuthService.sendPasswordResetEmail(email: self.emailLabel.text!, onSuccess: {
                ProgressHUD.showSuccess("メールの送信に成功しました！")
                UserDefaults.standard.set(nil, forKey: "Password")
                self.performSegue(withIdentifier: "PasswordResetSegue", sender: nil)
            }) { (error) in
                ProgressHUD.showError(error)
            }
        })
        
        let No = UIAlertAction(title: "キャンセル", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            
        })
        
        alertViewConroller.addAction(Yes)
        alertViewConroller.addAction(No)
        
        present(alertViewConroller, animated: true, completion: nil)
    }
    
    @IBAction func deleteUserBtn_touchUpInside(_ sender:Any){
        
        let alertViewConroller = UIAlertController(title: "本当にユーザーを削除しますか？", message: "削除されたアカウントは二度とログインできません。再度本アプリをお使いになる場合は、新しくアカウントを作り直してください。", preferredStyle: .actionSheet)
        
        let Yes = UIAlertAction(title: "アカウントを削除", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            ProgressHUD.show("ユーザーを削除しています。")
            let user = Auth.auth().currentUser
            user?.delete(completion: { (error) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                }else{
                    let deleteUserValue = Api.User.REF_USERS.child((user?.uid)!)
                    deleteUserValue.setValue(NSNull())
                    ProgressHUD.showSuccess("ユーザーを削除しました！")
                    UserDefaults.standard.set(nil, forKey: "Password")
                    let storyboard = UIStoryboard(name: "Start", bundle: nil)
                    let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                    self.present(signInVC, animated: true, completion: nil)
                }
            })
        })
        
        let No = UIAlertAction(title: "キャンセル", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            
        })
        alertViewConroller.addAction(Yes)
        alertViewConroller.addAction(No)
        
        present(alertViewConroller, animated: true, completion: nil)
        
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

