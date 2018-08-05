//
//  MessageApi.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/26.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class MessageApi{
    var REF_MESSAGES = Database.database().reference().child("messages")
    
    func observeMessages(withPostId id: String,completion: @escaping (MessageModel) -> Void){
        REF_MESSAGES.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newMessage = MessageModel.transformMessage(dict: dict)
                completion(newMessage)
            }
        })
    }
}
