//
//  RoomsViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class RoomsViewController: UIViewController {

    @IBOutlet weak var tableView:UITableView!
    var adress:String!
    var rooms = [RoomModel]()
    var users = [UserModel]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("adress \(self.adress)")
        tableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
    loadRoom()
    refreshControl.endRefreshing()
    }
    
    @objc func refresh(){
        rooms = [RoomModel]()
        users = [UserModel]()
        loadRoom()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func loadRoom(){
        ProgressHUD.show("読み込み中です", interaction: false)
        Api.Room.REF_ROOMS.observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                ProgressHUD.showSuccess("まだルームがありません！")
            }
        })
        
        Api.Room.REF_ROOMS.observe(.childAdded) { snapshot in
            print(Thread.isMainThread)
            if let dict = snapshot.value as? [String: Any] {
                guard (((dict["country"] as! String) + (dict["administrativeArea"] as! String) + (dict["subAdministrativeArea"] as! String) + (dict["locality"] as! String) + (dict["subLocality"] as! String) + (dict["thoroughfare"] as! String) ) == self.adress) else{
                    return ProgressHUD.showSuccess("まだ現在地付近にはルームがありません！")
                }
                
                let newRoom = RoomModel.transformRoom(dict: dict, key: snapshot.key)
                print("newRoom \(dict)")
                self.fetchUser(uid: newRoom.uid!, completion: {
                    self.rooms.insert(newRoom, at: 0)
                    self.tableView.reloadData()
                })
            }
            ProgressHUD.dismiss()
        }
    }
    
    func fetchUser(uid: String, completion:  @escaping () -> Void ){
        Api.User.REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                self.users.insert(user, at: 0)
                completion()
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageSegue"{
            let chatVC = segue.destination as! ChatViewController
            let roomId = sender as! String
            chatVC.roomId = roomId
        }
        
        if segue.identifier == "ProfileUserSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserVC.userId = userId
        }
        
        
    }
    
}

extension RoomsViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomsTableViewCell
        let room = rooms[indexPath.row]
        let user = users[indexPath.row]
        
        cell.room = room
        cell.user = user
        cell.delegate = self
        return cell
    }
    
}

extension RoomsViewController:RoomsTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ProfileUserSegue", sender: userId)
    }
    
    
    func goToChatVC(roomId: String) {
        performSegue(withIdentifier: "MessageSegue", sender: roomId)
    }
    
    
}
