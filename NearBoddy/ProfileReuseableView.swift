//
//  ProfileReuseableView.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/27.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
protocol ProfileReuseableViewDelegate {
    func updateFollowbutton(forUser user : UserModel)
}

protocol ProfileReuseableViewDelegateSwitchSettingVC{
    func goToSettingVC()
}

protocol ProfileReuseableViewDelegateSwitchMultipleVC {
    func goToMyPostVC(userId:String)
    func goToFollowingVC(userId:String)
    func goToFollowerVC(userId:String)
}

class ProfileReuseableView: UIView {

    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var settingImage:UIImageView!
    @IBOutlet weak var postCounterLabel:UILabel!
    @IBOutlet weak var headerImage:UIImageView!
    @IBOutlet weak var myPostCountLabel:UILabel!
    @IBOutlet weak var myRoomCountLabel:UILabel!
    @IBOutlet weak var followingCountLabel:UILabel!
    @IBOutlet weak var followerCountLabel:UILabel!
    
    var button:UIButton!
    var delegate:ProfileReuseableViewDelegate?
    var delegate2:ProfileReuseableViewDelegateSwitchSettingVC?
    var delegate3:ProfileReuseableViewDelegateSwitchMultipleVC?
    
    var user:UserModel?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
         self.nameLabel.text = user!.username
        print("user.username \(user?.username)")
        if let photoUrlString = user!.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
        
        if let photoUrlString2 = user!.headerImageUrl{
            let photoUrl = URL(string: photoUrlString2)
            self.headerImage.sd_setImage(with: photoUrl)
        }
       
        Api.MyRooms.fetchMyRoomsCount(userId: user!.id!) { (count) in
            self.myRoomCountLabel.text = "\(count)"
        }
        Api.MyPosts.fetchMyRoomsCount(userId: user!.id!) { (count) in
            self.myPostCountLabel.text = "\(count)"
        }
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        Api.Follow.fetchCountFollower(userId: user!.id!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
        
        
        if user?.id == Auth.auth().currentUser?.uid{
            settingImage.image = UIImage(named: "settings")
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToSettingVC))
            settingImage.addGestureRecognizer(tapGesture)
            settingImage.isUserInteractionEnabled = true
            
            let tapGesturePostCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToMyPostVC))
            myPostCountLabel.addGestureRecognizer(tapGesturePostCountLabel)
            myPostCountLabel.isUserInteractionEnabled = true
            
            let tapGestureFollowingCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToFollowingVC))
            followingCountLabel.addGestureRecognizer(tapGestureFollowingCountLabel)
            followingCountLabel.isUserInteractionEnabled = true
            
            let tapGestureFollowerCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToFollowerVC))
            followerCountLabel.addGestureRecognizer(tapGestureFollowerCountLabel)
            followerCountLabel.isUserInteractionEnabled = true
            
        }else{
            updateStateFollowButton()
            
            let tapGesturePostCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToMyPostVC))
            myPostCountLabel.addGestureRecognizer(tapGesturePostCountLabel)
            myPostCountLabel.isUserInteractionEnabled = true
            
            let tapGestureFollowingCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToFollowingVC))
            followingCountLabel.addGestureRecognizer(tapGestureFollowingCountLabel)
            followingCountLabel.isUserInteractionEnabled = true
            
            let tapGestureFollowerCountLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToFollowerVC))
            followerCountLabel.addGestureRecognizer(tapGestureFollowerCountLabel)
            followerCountLabel.isUserInteractionEnabled = true
        }
    }
    
    @objc func goToSettingVC(){
        delegate2?.goToSettingVC()
    }
    
    @objc func goToMyPostVC(){
        delegate3?.goToMyPostVC(userId: user!.id!)
    }
    
    @objc func goToFollowingVC(){
        delegate3?.goToFollowingVC(userId: user!.id!)
    }
    
    @objc func goToFollowerVC(){
        delegate3?.goToFollowerVC(userId: user!.id!)
    }
    
    
    func updateStateFollowButton(){
        if user?.isFollowing == true {
            configureUnFollowButton()
        }else{
            configureFollowButton()
        }
    }
    
    
    func configureFollowButton(){
        settingImage.image = UIImage(named: "follow")
        
        let tapGesturefollowImage = UITapGestureRecognizer(target: self, action: #selector(self.followAction))
        settingImage.addGestureRecognizer(tapGesturefollowImage)
        settingImage.isUserInteractionEnabled = true
    }
    
    func configureUnFollowButton(){
         settingImage.image = UIImage(named: "unfollow")
        
        let tapGestureunfollowImage = UITapGestureRecognizer(target: self, action: #selector(self.unFollowAction))
        settingImage.addGestureRecognizer(tapGestureunfollowImage)
        settingImage.isUserInteractionEnabled = true
       
    }
    
    @objc func followAction() {
        if user?.isFollowing! == false{
            print("tap1")
            ProgressHUD.showSuccess("フォローしました！")
            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing! = true
            delegate?.updateFollowbutton(forUser: user!)
        }
        
    }
    
    @objc func unFollowAction(){
        if user?.isFollowing! == true{
            print("tap2")
            ProgressHUD.showSuccess("フォローを解除しました！")
            Api.Follow.unfollowAction(withUser: user!.id!)
            configureFollowButton()
            user?.isFollowing! = false
        }
    }
    
}
