//
//  ProfileUserViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/30.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController {

    var user:UserModel!
    var rooms:[RoomModel] = []
    var userId = ""
    var delegate:ProfileReuseableViewDelegate?
    var delegate2:ProfileReuseableViewDelegateSwitchSettingVC?
    var refreshControl = UIRefreshControl()
    
     @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var ProfileReuseableView: ProfileReuseableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchUser()
        fetchMyRooms()
        refreshControl.endRefreshing()
    }
    
    @objc func refresh(){
        rooms = [RoomModel]()
        fetchUser()
        fetchMyRooms()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func fetchUser(){
        Api.User.observeUser(withId: userId) { (user) in
            self.isFollowing(userId:user.id!, completed: {
                value in
                user.isFollowing = value
                self.user = user
                self.ProfileReuseableView.user = user
                self.ProfileReuseableView.delegate = self.delegate
                self.ProfileReuseableView.delegate2 = self
                self.ProfileReuseableView.delegate3 = self
                self.navigationItem.title = user.username
                self.tableView.reloadData()
            })
        }
    }
    
    func isFollowing(userId:String,completed: @escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    func fetchMyRooms(){
        Api.MyRooms.fetchMyRooms(userId: userId, completion: {
            key in
            Api.Room.observeRoom(withId: key, completion: {
                room in
                print(room.id!)
                self.rooms.insert(room, at: 0)
                self.tableView.reloadData()
            })
        })
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageSegue"{
            let chatVC = segue.destination as! ChatViewController
            let roomId = sender as! String
            chatVC.roomId = roomId
        }
        
        if segue.identifier == "MyPostSegue"{
            let myPostVC = segue.destination as! MyPostsViewController
            let userId = sender as! String
            myPostVC.userId = userId
        }
        
        if segue.identifier == "FollowingSegue"{
            let followingVC = segue.destination as! FollowingViewController
            let userId = sender as! String
            followingVC.userId = userId
        }
        
        if segue.identifier == "FollowerSegue"{
            let followerVC = segue.destination as! FollowerViewController
            let userId = sender as! String
            followerVC.userId = userId
        }
    }
    
}


extension ProfileUserViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomsTableViewCell
        let room = rooms[indexPath.row]
        let user = self.user
        
        cell.room = room
        cell.user = user
        cell.delegate = self
        
        return cell
    }
    
}

extension ProfileUserViewController:RoomsTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        print("tapping")
    }
    
    
    func goToChatVC(roomId: String) {
        performSegue(withIdentifier: "MessageSegue", sender: roomId)
    }
}

extension ProfileUserViewController: ProfileReuseableViewDelegateSwitchMultipleVC{
    func goToFollowingVC(userId: String) {
        performSegue(withIdentifier: "FollowingSegue", sender: userId)
    }
    
    func goToFollowerVC(userId: String) {
        performSegue(withIdentifier: "FollowerSegue", sender: userId)
    }
    
    func goToMyPostVC(userId: String) {
        performSegue(withIdentifier: "MyPostSegue", sender: userId)
    }
}
extension ProfileUserViewController: ProfileReuseableViewDelegateSwitchSettingVC{
    func goToSettingVC() {
        performSegue(withIdentifier: "ProfileUser_SettingSegue", sender: nil)
    }
}
