//
//  ProfileViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ProfileReuseableView: ProfileReuseableView!
    
    var user:UserModel!
    var rooms = [RoomModel]()
     var refreshControl = UIRefreshControl()
    var count:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        print("現在のユーザー:   \(Auth.auth().currentUser)")
        fetchUser()
    }
    
    func fetchUser(){
        Api.User.observeCurrentUser { (user) in
            self.user = user
            self.ProfileReuseableView.user = user
            self.ProfileReuseableView.delegate2 = self
            self.ProfileReuseableView.delegate3 = self
            self.navigationItem.title = user.username
            self.tableView.reloadData()
        }
    }
    
    func fetchMyRooms(){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        ProgressHUD.show("読み込んでいます...")
        Api.MyRooms.REF_MYROOMS.child(currentUser.uid).observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                ProgressHUD.showSuccess("まだルームがありません！")
            }
        })
        
        Api.MyRooms.REF_MYROOMS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            Api.Room.observeRoom(withId: snapshot.key, completion: { (room) in
                print(room.id!)
                self.rooms.insert(room, at: 0)
                self.tableView.reloadData()
            })
            ProgressHUD.dismiss()
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


extension ProfileViewController: UITableViewDataSource,UITableViewDelegate{
    
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
extension ProfileViewController:SettingTableViewControllerDelegate{
    func updateUserInfo() {
        self.fetchUser()
    }
}

extension ProfileViewController: ProfileReuseableViewDelegateSwitchSettingVC{
    func goToSettingVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
}

extension ProfileViewController: ProfileReuseableViewDelegateSwitchMultipleVC{
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


extension ProfileViewController:RoomsTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        print("tapping")
    }
    
    
    func goToChatVC(roomId: String) {
        performSegue(withIdentifier: "MessageSegue", sender: roomId)
    }
    
    
}
