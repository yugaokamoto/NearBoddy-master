//
//  NotificationModel.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/31.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase
class NotificationModel{
    var from:String?
    var objectId:String?
    var type:String?
    var timestamp:Int?
    var id:String?
}

extension NotificationModel {
    static func transform(dict: [String: Any],key: String) -> NotificationModel {
        let notification = NotificationModel()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.from = dict["from"] as? String
        
        return notification
    }
}
