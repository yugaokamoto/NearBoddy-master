//
//  FollowingViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/31.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import ProgressHUD
class FollowingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var users : [UserModel] = []
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 77
        loadUser()
    }
    
    func loadUser(){
        
        ProgressHUD.show("読み込んでいます...")
        Api.Follow.fetchMyFollowings(userId: userId) { (key) in
            Api.User.observeUser(withId: key, completion: { (user) in
                self.isFollowing(userId:user.id!, completed: {
                    value in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                    ProgressHUD.dismiss()
                })
            })
        }
        
    }
    
    func isFollowing(userId:String,completed: @escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileUserSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserVC.userId = userId
            profileUserVC.delegate = self
        }
    }
    
}


extension FollowingViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension FollowingViewController:PeopleTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ProfileUserSegue", sender: userId)
    }
}

extension FollowingViewController:ProfileReuseableViewDelegate{
    
    func updateFollowbutton(forUser user: UserModel) {
        for u in self.users{
            if u.id == user.id{
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}




