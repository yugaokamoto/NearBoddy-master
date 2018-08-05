//
//  Notification.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/31.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id:String,completion: @escaping (NotificationModel) -> Void){
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any]{
                let newNoti = NotificationModel.transform(dict: dict, key: snapshot.key)
                completion(newNoti)
            }
        })
    }
    
}
