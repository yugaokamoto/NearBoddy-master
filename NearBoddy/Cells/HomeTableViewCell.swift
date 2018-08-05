//
//  HomeTableViewCell.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/26.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

protocol HomeTableViewCellDelegate {
    func goToProfileUserVC(userId:String)
}

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var timestampLabel:UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var captionLabel:UILabel!
    var delegate :HomeTableViewCellDelegate?
    
    var post:PostModel?{
        didSet{
            updateView()
        }
    }
    
    var user:UserModel?{
        didSet{
            setUserInfo()
        }
    }
    
    func updateView(){
        
        locationLabel.text = post?.location
        captionLabel.text = post?.caption
        
        if let timestamp = post?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            timestampLabel.text = timeText
        }
    }
    
    func setUserInfo(){
        userNameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        userNameLabel.addGestureRecognizer(tapGesture)
        userNameLabel.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        profileImageView.addGestureRecognizer(tapGesture2)
        profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func nameLabel_TouchUpInside(){
        print("touch")
        if let id = user?.id{
            delegate?.goToProfileUserVC(userId: id)
            print("\(id)")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
