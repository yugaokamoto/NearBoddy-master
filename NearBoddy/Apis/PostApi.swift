//
//  PostApi.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/24.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
class PostApi{
    var REF_POSTS = Database.database().reference().child("Posts")
    
    
    func observePost(withId id:String, completion: @escaping (PostModel) -> Void){
        REF_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = PostModel.transformPost(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
}
