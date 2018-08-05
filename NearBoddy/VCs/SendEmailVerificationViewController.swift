//
//  SendEmailVerificationViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/08/05.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import ProgressHUD

class SendEmailVerificationViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signIn_Btn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleTextField()
        
    }
    
    
    func handleTextField(){
        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
      
        
    }
    
    @objc func textFieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty else{
            
            signIn_Btn.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signIn_Btn.isEnabled = false
            return
        }
        signIn_Btn.setTitleColor(.white, for: UIControlState.normal)
        signIn_Btn.isEnabled = true
    }
    

    @IBAction func sendEmailVerification( _ sender: Any){
        ProgressHUD.show("Wating for...", interaction: false)
        AuthService.sendPasswordResetEmail(email: emailTextField.text!, onSuccess: {
            self.performSegue(withIdentifier: "mailSegue", sender: nil)
        }) { (error) in
            ProgressHUD.showError(error!)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func back( _ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }

}
