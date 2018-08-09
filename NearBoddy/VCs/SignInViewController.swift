//
//  SignInViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//
import UIKit
import ProgressHUD
import Firebase
class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signIn_Btn: UIButton!
    
//    var Link :String?
    var Password:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleTextField()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        let defalts = UserDefaults.standard
        let hasViewedWalkthrough = defalts.bool(forKey: "hasViewedWalkthrough")
        if hasViewedWalkthrough != true{
            if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughPageViewController") as? WalkthroughPageViewController{
                present(pageVC, animated: true, completion: nil)
            }
        }
        
        if let password = UserDefaults.standard.value(forKey: "Password") as? String {
            self.Password = password
        }
        print("Password2: \(self.Password)")
        if Password != nil{
            performSegue(withIdentifier: "signInToTabBar", sender: nil)
        }

    }
 
    
    func handleTextField(){
        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    @objc func textFieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else{
            
            signIn_Btn.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signIn_Btn.isEnabled = false
            return
        }
        signIn_Btn.setTitleColor(.white, for: UIControlState.normal)
        signIn_Btn.isEnabled = true
    }
    
    
    @IBAction func signIn_touchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("ログインしています...", interaction: false)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess:{
            ProgressHUD.showSuccess("ログインに成功しました！")
            self.performSegue(withIdentifier: "signInToTabBar", sender: nil)
        }, onError:{error in
            ProgressHUD.showError(error!)
        })
        
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
