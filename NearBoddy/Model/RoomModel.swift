//
//  Room.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/25.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
class RoomModel {

    var id: String?
    var uid:String?
    var roomName:String?
    var roomPhotoUrl:String?
    var timestamp:Int?
    var country:String?
    var administrativeArea:String?
    var subAdministrativeArea:String?
    var locality:String?
    var subLocality:String?
    var thoroughfare:String?
    var subThoroughfare:String?

}

extension RoomModel {
    static func transformRoom(dict: [String: Any],key: String) -> RoomModel {
        let room = RoomModel()
        room.id = key
        room.roomName = dict["roomName"] as? String
        room.roomPhotoUrl = dict["roomPhotoUrl"] as? String
        room.uid = dict["uid"] as? String
        room.timestamp = dict["timestamp"] as? Int
        room.country = dict["country"] as? String
        room.administrativeArea = dict["administrativeArea"] as? String
        room.subAdministrativeArea = dict["subAdministrativeArea"] as? String
        room.locality = dict["locality"] as? String
        room.subLocality = dict["subLocality"] as? String
        room.thoroughfare = dict["thoroughfare"] as? String
        room.subThoroughfare = dict["subThoroughfare"] as? String
        return room
    }
    
}
