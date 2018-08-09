//
//  NotificationViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationModel]()
    var users = [UserModel]()
    var refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        loadNotifications()
        refreshControl.endRefreshing()
    }
    
    @objc func refresh(){
       notifications = [NotificationModel]()
       users = [UserModel]()
        loadNotifications()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadNotifications() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        ProgressHUD.show("読み込んでいます。")
            Api.Notification.REF_NOTIFICATION.child(currentUser.uid).observe(.value, with: { (snapshot) in
                if !snapshot.exists() {
                    ProgressHUD.showSuccess("まだ通知はありません")
                }
            })
        
        Api.Notification.observeNotification(withId: currentUser.uid , completion: {
            notification in
            guard let uid = notification.from else {
                return
            }
            self.fetchUser(uid: uid, completed: {
                self.notifications.insert(notification, at: 0)
                print("notification: \(notification)")
                self.tableView.reloadData()
            })
          ProgressHUD.dismiss()
        })
    }
    
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "Notification_ProfileUserSegue" {
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileUserVC.userId = userId
        }
        
        if segue.identifier == "Notification_ChatSegue" {
            let chatVC = segue.destination as! ChatViewController
            let roomId = sender  as! String
            chatVC.roomId = roomId
        }
    }
}


extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notification = notification
        cell.user = user
        cell.delegate = self
        return cell
    }
}
extension NotificationViewController:NotificationTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Notification_ProfileUserSegue", sender: userId)
    }
    
    func goToMessageVC(roomId: String) {
        performSegue(withIdentifier: "Notification_ChatSegue", sender: roomId)
    }
    
   
    
}

