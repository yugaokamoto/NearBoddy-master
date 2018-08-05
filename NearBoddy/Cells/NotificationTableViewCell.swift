//
//  NotificationTableViewCell.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/31.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
protocol  NotificationTableViewCellDelegate{
    func goToProfileUserVC(userId: String)
    func goToMessageVC(roomId: String)
}

class NotificationTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var delegate:NotificationTableViewCellDelegate?
    
    var notification:NotificationModel? {
        didSet{
            updateView()
        }
        
    }
    
    var user:UserModel?{
        didSet{
            setUpUserInfo()
        }
    }
    
    func updateView(){
        switch notification!.type! {
       
        case "message":
            descriptionLabel.text = "あなたのルームにメッセージがあります。"
            
            let objectId = notification!.objectId!
            Api.Room.observeRoom(withId: objectId, completion: { (room) in
                if let photoUrlString = room.roomPhotoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photo.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
            
        case "follow":
            descriptionLabel.text = "あなたをフォローし始めました！"
            self.photo.image = UIImage(named: "placeholderImg")

        default:
            print("")
        }
        
        if let timestamp = notification?.timestamp {
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!)s"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!)m"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!)h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!)d"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            
            timeLabel.text = timeText
        }
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.cell_TouchUpInside))
        addGestureRecognizer(tapGestureForPhoto)
        isUserInteractionEnabled = true
        
    }
    
    @objc func cell_TouchUpInside (){
        if let id = notification?.objectId {
            if notification!.type! == "follow" {
                delegate?.goToProfileUserVC(userId: id)
            } else if notification!.type! == "message" {
                delegate?.goToMessageVC(roomId: id)
            }
        }
        
    }
    
    func setUpUserInfo(){
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
            profileView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named:"placeholderImg"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
