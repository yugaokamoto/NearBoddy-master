//
//  Api.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/24.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import Foundation
struct Api {
    
    static var Post = PostApi()
    static var Room = RoomApi()
    static var User = UserApi()
    static var Message = MessageApi()
    static var Room_Message = Room_MessageApi()
    static var MyRooms = MyRoomsApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Notification = NotificationApi()
    
}
