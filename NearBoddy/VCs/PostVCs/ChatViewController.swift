//
//  ChatViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/26.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class ChatViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    
    var roomId :String!
    var messages = [MessageModel]()
    var users = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        tableView.dataSource = self
        sendButton.isEnabled = false
        handleTextField()
        empty()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        let keyboardframe = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = keyboardframe!.height
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        print(notification)
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func loadComments(){
        ProgressHUD.show("読み込み中です...")
        
        //snapshotの有無確認
        Api.Room_Message.REF_ROOM_MESSAGES.child(self.roomId!).observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                ProgressHUD.showSuccess("まだ会話がありません！")
            }
        })
        
     Api.Room_Message.REF_ROOM_MESSAGES.child(self.roomId!).observe(.childAdded, with: {
            snapshot in
    
        print("snapshot:\(snapshot)")
            Api.Message.observeMessages(withPostId: snapshot.key, completion: { message in
                self.fetchUser(uid: message.uid!, completed: {
                    self.messages.append(message)
                    self.tableView.reloadData()
                })
            })
        })
        
    }
    
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
        
        Api.User.observeUser(withId: uid, completion: { user in
            self.users.append(user)
            completed()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func handleTextField() {
        messageTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let messageText = messageTextField.text, !messageText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    
    @IBAction func sendButton_touchUpInside(_ sender: Any) {
        
        let newMessageId = Api.Message.REF_MESSAGES.childByAutoId().key
        let newMessageReference = Api.Message.REF_MESSAGES.child(newMessageId)
        //newpostReference = Database.database().reference().child("Posts").child(newPostId)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        newMessageReference.setValue(["uid": currentUserId,"messageText": messageTextField.text!,"timestamp":timestamp], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
         
            
            let roomMessageRef = Api.Room_Message.REF_ROOM_MESSAGES.child(self.roomId!).child(newMessageId)
            roomMessageRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                Api.Room.observeRoom(withId: self.roomId, completion: { (room) in
                    if room.uid! != Auth.auth().currentUser!.uid {
                        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                        let newNotificationId = Api.Notification.REF_NOTIFICATION.child(room.uid!).childByAutoId().key
                        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(room.uid!).child(newNotificationId)
                        newNotificationReference.setValue( ["from": Auth.auth().currentUser!.uid, "objectId": self.roomId!, "type": "message", "timestamp": timestamp])
                    }
                })
            })
            self.empty()
            self.view.endEditing(true)
        })
        
    }
    
    func empty(){
        self.messageTextField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Message_ProfileSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserVC.userId = userId
        }
//
//        if segue.identifier == "Comment_HashTagSegue"{
//            let hashTagVC = segue.destination as! HashTagViewController
//            let tag = sender as! String
//            hashTagVC.tag = tag
//        }
        
    }
    
    
}


extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        let message = messages[indexPath.row]
        let user = users[indexPath.row]
        cell.message = message
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension ChatViewController:MessageTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Message_ProfileSegue" , sender: userId)
    }
}

