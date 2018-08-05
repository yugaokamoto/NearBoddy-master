//
//  File.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
import ProgressHUD
class AuthService{
    
    static func signIn(email:String, password:String, onSuccess:@escaping () -> Void, onError:@escaping (_ errorMessage:String?)->Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            
            if (Auth.auth().currentUser?.isEmailVerified)! == false{
                ProgressHUD.showError("まだメールアドレスの認証が済んでいません")
                Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                ProgressHUD.showError("本人確認メールをアドレスに送信しました。確認して認証を済ませてください。")
                })
                
            }else{
                UserDefaults.standard.set(password, forKey: "Password")
                print("メールアドレスの確認が済みです。")
                onSuccess()
            }
            
        }
    }
    
    
    static func sendPasswordResetEmail(email:String, onSuccess:@escaping () -> Void, onError:@escaping (_ errorMessage:String?)->Void){
      
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
       
    }
    
//    static func signInLink(email:String, link:String, onSuccess:@escaping () -> Void, onError:@escaping (_ errorMessage:String?)->Void){
//
//        Auth.auth().signIn(withEmail: email, link: link) { (user, error) in
//            if error != nil{
//                onError(error!.localizedDescription)
//                return
//            }
//            onSuccess()
//        }
//    }
    
    
    static func signUp(username:String, email:String, password:String, imageData:Data,imageData2: Data, onSuccess:@escaping () -> Void, onError:@escaping (_ errorMessage:String?)->Void){
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            let user = Auth.auth().currentUser
//            let actionCodeSettings =  ActionCodeSettings.init()
//            actionCodeSettings.handleCodeInApp = true
//            actionCodeSettings.url = URL(string: "https://nearboddy.page.link/jdXk")
//            actionCodeSettings.setIOSBundleID("com.gmail.imnot.wimp119.NearBoddy")
//
//            Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings, completion: { (error) in
//                if error != nil{
//                    onError(error?.localizedDescription)
//                    return
//                }
//                UserDefaults.standard.set(email, forKey: "Email")
//                print("Check your email for link")
//
//            })
            
            user?.sendEmailVerification(completion: { (error) in
                if error != nil {
                    onError(error!.localizedDescription)
                    return
                }
            })
            
            
            let uid = user?.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF ).child("profile_image").child(uid!)
            let storageRef2 = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF ).child("header_image").child(uid!)
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    return
                }
               
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    let profileImageUrl = url!.absoluteString
                    
                    storageRef2.putData(imageData2, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            return
                        }
                        storageRef2.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print(error!)
                                return
                            }
                            let headerImageUrl = url!.absoluteString
                            self.setInfomation(profileImageUrl: profileImageUrl, headerImageUrl: headerImageUrl, username: username, email:  email, uid: uid!, onSuccess: onSuccess)
                        })
                    })
                })
            })
        })
    }
    
    static func updateUserInfo(username:String, email:String, imageData:Data,imageData2:Data ,onSuccess:@escaping () -> Void, onError:@escaping (_ errorMessage:String?)->Void){
        
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            let user = Auth.auth().currentUser
            let uid = user?.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF ).child("profile_image").child(uid!)
            let storageRef2 = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF ).child("header_image").child(uid!)
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    return
                }
                //error: let profileImageUrl = metadata?.downloadURL()?.absoluteString
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil{
                        return
                    }
                    let profileImageUrl = url!.absoluteString
                    storageRef2.putData(imageData2, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            return
                        }
                        storageRef2.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print(error!)
                                return
                            }
                            let headerImageUrl = url!.absoluteString
                            self.updateDatabase(profileImageUrl: profileImageUrl,headerImageUrl:headerImageUrl, username: username, email: email, onSuccess: onSuccess, onError: onError)
                        })
                    })
                })
            })
        })
    }
    
    static func setInfomation(profileImageUrl:String,headerImageUrl:String, username:String, email:String, uid:String, onSuccess:@escaping () -> Void){
        let ref = Database.database().reference()
        let userReference = ref.child("users")
        let newuserReference = userReference.child(uid)
        //newuserReference = Database.database().reference().child("users").child(uid!)
        
        newuserReference.setValue(["username": username,"username_lowercase":username.lowercased(), "email":email, "profileImageUrl":profileImageUrl,"headerImageUrl":headerImageUrl])
        onSuccess()
    }
    
    static  func updateDatabase(profileImageUrl:String, headerImageUrl:String, username:String, email:String, onSuccess:@escaping () -> Void,onError:@escaping (_ errorMessage:String?)->Void){
        let dict = ["username": username,"username_lowercase":username.lowercased(), "email":email, "profileImageUrl":profileImageUrl,"headerImageUrl":headerImageUrl]
        Api.User.REF_CRRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil{
                onError(error!.localizedDescription)
            }
            onSuccess()
        })
        
    }
    
    static func logOut(onSuccess:@escaping () -> Void, onError:@escaping (_ errorMessage:String?)->Void){
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.set(nil, forKey: "Link")
            UserDefaults.standard.set(nil, forKey: "Password")
            onSuccess()
        }catch let logerror {
            print(logerror.localizedDescription)
        }
    }
}
