//
//  PeopleViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/30.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    var searchBar = UISearchBar()
    @IBOutlet weak var tableView: UITableView!
    var users : [UserModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        doSearch()
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
//        loadUser()
    }
    
//    func loadUser(){
//        Api.User.observeUsers { (user) in
//            self.isFollowing(userId:user.id!, completed: {
//                value in
//                user.isFollowing = value
//                self.users.append(user)
//                self.tableView.reloadData()
//            })
//        }
//    }
    
    func doSearch(){
        if let searchText = searchBar.text?.lowercased(){
            self.users.removeAll()
            self.tableView.reloadData()
            Api.User.queryUser(withText: searchText) { (user) in
                self.isFollowing(userId:user.id!, completed: {
                    value in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                })
                
            }
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

extension PeopleViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
    
}

extension PeopleViewController: UITableViewDataSource{

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

extension PeopleViewController:PeopleTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ProfileUserSegue", sender: userId)
    }
}

extension PeopleViewController:ProfileReuseableViewDelegate{
    
    func updateFollowbutton(forUser user: UserModel) {
        for u in self.users{
            if u.id == user.id{
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}


