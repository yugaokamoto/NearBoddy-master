//
//  MyPostsApi.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/30.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
import ProgressHUD

class MyPostsApi {
    var REF_MYPOSTS = Database.database().reference().child("myPosts")
    
    func fetchMyPosts(userId:String, completion: @escaping (String) -> Void){
        REF_MYPOSTS.child(userId).observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
            ProgressHUD.showSuccess("まだ投稿がありません！")
        }
    })
        
        REF_MYPOSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchMyRoomsCount(userId:String, completion: @escaping (Int) -> Void){
        REF_MYPOSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
        
    }
}
