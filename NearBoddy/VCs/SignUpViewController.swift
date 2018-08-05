//
//  SignUpViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import ProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUp_Btn: UIButton!
    
    var selectedImage: UIImage!
    var Link:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        signUp_Btn.isEnabled = false
        handleTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let link = UserDefaults.standard.value(forKey: "Link") as? String {
            self.Link = link
        }
        print("\(self.Link)")
        if Link == nil{
            //            performSegue(withIdentifier: "signUp", sender: nil)
        }else{
            if Auth.auth().isSignIn(withEmailLink: Link!) {
                performSegue(withIdentifier: "signUpToTabBar", sender: nil)
            }
        }
        //        if Auth.auth().currentUser != nil{
        //            performSegue(withIdentifier: "signInToTabBar", sender: nil)
        //        }
    }
    
    func handleTextField(){
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    @objc func textFieldDidChange(){
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else{
            
            signUp_Btn.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signUp_Btn.isEnabled = false
            return
        }
        signUp_Btn.setTitleColor(.white, for: UIControlState.normal)
        signUp_Btn.isEnabled = true
    }
    
    @objc func handleSelectProfileView(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func dismiss_touchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp_touchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Wating for...", interaction: false)
        if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1){
            let imageData2 = UIImageJPEGRepresentation(UIImage(named: "Placeholder-image")!, 0.1)
            AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData,imageData2: imageData2!, onSuccess: {
                ProgressHUD.showSuccess("ユーザーの作成に成功しました。")
                self.performSegue(withIdentifier: "mailSegue", sender: nil)
            }, onError: { (errorString) in
                ProgressHUD.showError(errorString!)
            })
        }else{
            ProgressHUD.showError("画像を選択してください。")
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
