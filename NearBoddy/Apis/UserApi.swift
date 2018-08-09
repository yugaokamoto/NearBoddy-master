//
//  UserApi.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/25.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
class UserApi{
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUser(withId uid: String, completion: @escaping (UserModel) -> Void){
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    
    func observeCurrentUser(completion: @escaping (UserModel) -> Void){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    
    func observeUsers(completion: @escaping (UserModel) -> Void){
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                if user.id != Auth.auth().currentUser?.uid{
                    completion(user)
                }
            }
        })
    }
    
    func queryUser(withText text: String,completion: @escaping (UserModel) -> Void){
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: {
            snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let user = UserModel.transformUser(dict: dict, key: child.key)
                    if user.id != Auth.auth().currentUser?.uid{
                        completion(user)
                    }
                }
            })
        })
    }
    
    var REF_CRRENT_USER: DatabaseReference?{
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }
    
}
