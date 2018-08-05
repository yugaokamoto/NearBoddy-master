//
//  HomeViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
class HomeViewController: UIViewController {

    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView:UITableView!
    var posts = [PostModel]()
    var users = [UserModel]()
    
    let currentUser = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
    tableView.dataSource = self
        
//        emailveridation()
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
//        print("Userdefaults: \(UserDefaults.standard.value(forKey: "Link"))")
    loadPost()
    refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailveridation()
    }

    @objc func refresh(){
        posts = [PostModel]()
        users = [UserModel]()
        loadPost()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func emailveridation(){
        if (currentUser?.isEmailVerified)! == false {
             print("userのメールアドレスはまだ確認されていません")
        }else{
          print("メールアドレスは確認済みです。")

        }
    }
    
    
    func loadPost(){
        ProgressHUD.show("読み込み中です", interaction: false)
        Api.Post.REF_POSTS.observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                ProgressHUD.showSuccess("まだ投稿がありません！")
            }
        })
        
        Api.Post.REF_POSTS.observe(.childAdded) { snapshot in
            print(Thread.isMainThread)
            if let dict = snapshot.value as? [String: Any] {
                
                let newPost = PostModel.transformPost(dict: dict, key: snapshot.key)
//                print("newRoom \(dict)")
                self.fetchUser(uid: newPost.uid!, completion: {
                    self.posts.insert(newPost, at: 0)
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

    @IBAction func logOut_touchUpInside(_ sender: Any) {
        AuthService.logOut(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
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

extension HomeViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension HomeViewController:HomeTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ProfileUserSegue", sender: userId)
    }
}

extension HomeViewController:ProfileReuseableViewDelegate{
    
    func updateFollowbutton(forUser user: UserModel) {
        for u in self.users{
            if u.id == user.id{
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}

