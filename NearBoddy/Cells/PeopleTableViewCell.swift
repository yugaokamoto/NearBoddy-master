//
//  PeopleTableViewCell.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/30.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase

protocol PeopleTableViewCellDelegate {
    func goToProfileUserVC(userId:String)
}


class PeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var delegate:PeopleTableViewCellDelegate?
    var user:UserModel?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named:"placeholderImg"))
        }
        
        if user?.isFollowing == true {
            configureUnFollowButton()
        }else{
            configureFollowButton()
        }
        
    }
    
    func configureFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 233/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 233/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.blue
        followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing! == false{
            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing! = true
        }
        
    }
    
    @objc func unFollowAction(){
        if user?.isFollowing! == true{
            Api.Follow.unfollowAction(withUser: user!.id!)
            configureFollowButton()
            user?.isFollowing! = false
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGesture)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func nameLabel_TouchUpInside(){
        if let id = user?.id{
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
