//
//  MyRooms.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/27.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
import Firebase

class MyRoomsApi {
    var REF_MYROOMS = Database.database().reference().child("myRooms")
    
    func fetchMyRooms(userId:String, completion: @escaping (String) -> Void){
        REF_MYROOMS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchMyRoomsCount(userId:String, completion: @escaping (Int) -> Void){
        REF_MYROOMS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    
   }
}
