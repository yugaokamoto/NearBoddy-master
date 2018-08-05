//
//  MyPostsViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/31.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import ProgressHUD
class MyPostsViewController: UIViewController {

    @IBOutlet weak var tableView:UITableView!
    var users = [UserModel]()
    var posts = [PostModel]()
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        loadPost()
    }

    func loadPost(){
        ProgressHUD.show("読み込み中です", interaction: false)
    
        Api.MyPosts.fetchMyPosts(userId: userId) { (key) in
            Api.Post.observePost(withId: key, completion: { (post) in
                self.fetchUser(uid: post.uid!, completion: {
                    self.posts.insert(post, at: 0)
                    self.tableView.reloadData()
                    ProgressHUD.dismiss()
            })
        })
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
}


extension MyPostsViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        
        cell.post = post
        cell.user = user
        return cell
    }
}


