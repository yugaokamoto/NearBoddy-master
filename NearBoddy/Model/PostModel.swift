//
//  PostModel.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/26.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
class PostModel {
    
    var caption: String?
    var location: String?
    var uid: String?
    var timestamp:Int?
    var id:String?
    
}
extension PostModel {
    static func transformPost(dict: [String: Any],key:String) -> PostModel {
        let post = PostModel()
        post.id = key
        post.caption = dict["caption"] as? String
        post.location = dict["location"] as? String
        post.timestamp = dict["timestamp"] as? Int
        post.uid = dict["uid"] as? String
        return post
   }
}
