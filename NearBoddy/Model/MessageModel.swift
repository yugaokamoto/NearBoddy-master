//
//  MessageModel.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/26.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation

class MessageModel {
    
    var messageText: String?
    var timestamp:Int?
    var uid: String?
}

extension MessageModel {
    static func transformMessage(dict: [String: Any]) -> MessageModel {
        let message = MessageModel()
        message.messageText = dict["messageText"] as? String
        message.timestamp = dict["timestamp"] as? Int
        message.uid = dict["uid"] as? String
        return message
    }
}
