//
//  RoomApi.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/25.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class RoomApi{
    var REF_ROOMS = Database.database().reference().child("Rooms")
//
//    func observeRooms(completion: @escaping (RoomModel) -> Void){
//        REF_ROOMS.observe(.childAdded) { (snapshot: DataSnapshot) in
//            if let dict = snapshot.value as? [String: Any] {
//                let newRoom = RoomModel.transformRoom(dict: dict, key: snapshot.key)
//                completion(newRoom)
//            }
//        }
//    }
    func observeRoom(withId id:String, completion: @escaping (RoomModel) -> Void){
        REF_ROOMS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let room = RoomModel.transformRoom(dict: dict, key: snapshot.key)
                completion(room)
            }
        })
    }

}
