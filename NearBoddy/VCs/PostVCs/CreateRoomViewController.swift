//
//  CreateRoomViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import CoreLocation
import ProgressHUD
import Firebase

class CreateRoomViewController: UIViewController ,CLLocationManagerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    @IBOutlet weak var NowlocationLabel:UILabel!
    @IBOutlet weak var roomNameTextField:UITextField!
    @IBOutlet weak var photo: UIImageView!
     @IBOutlet weak var shareButton: UIButton!
    var selectedImage :UIImage!
    var LModel:LocationModel = LocationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
        catchLocationData()
    }
    
    
    func catchLocationData(){
        
        if CLLocationManager.locationServicesEnabled() {
            LModel.locationManager = CLLocationManager()
            LModel.locationManager.delegate = self
            LModel.locationManager.startUpdatingLocation()
        }
    }
    @objc func handleSelectPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "roomsVC" {
            let roomsVC = segue.destination as! RoomsViewController
            self.LModel.address = self.LModel.country + self.LModel.administrativeArea + self.LModel.subAdministrativeArea
                + self.LModel.locality + self.LModel.subLocality + self.LModel.thoroughfare
            roomsVC.adress = self.LModel.address
        }
    }
    
    @IBAction func shareRoom_touchUpInside(){
      postRooms()
    }
    
    func postRooms(){
        reverseGeocode(latitude: LModel.ido!, longitude: LModel.keido!)
        ProgressHUD.show("作成しています...", interaction: false)
        guard let roomName = roomNameTextField.text,!roomName.isEmpty else {
            ProgressHUD.showError("部屋名を入力してください")
            return
        }
        if let roomImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(roomImage, 0.1){
           uploadDataToServer(data: imageData, roomName: roomNameTextField.text!, onSuccess:{
                self.clean_items()
                self.performSegue(withIdentifier: "roomsVC", sender: nil)
            })
        }else{
            ProgressHUD.showError("画像を選択してください")
        }
    }
     func uploadDataToServer(data:Data, roomName: String,onSuccess: @escaping  () -> Void){
        uploadImageToFirebaseStorage(data: data) { (roomPhotoUrl) in
            self.sendDataToDatabase(roomPhotoUrl: roomPhotoUrl, roomName: roomName, onSuccess: onSuccess)
        }
    }
    
     func uploadImageToFirebaseStorage(data: Data, onSuccess:  @escaping  (_ imageUrl:String) -> Void){
        let photoIDString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF ).child("rooms").child(photoIDString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil{
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                if let roomPhotoUrl = url?.absoluteString {
                    onSuccess(roomPhotoUrl)
                }
            })
        }
    }
    
     func sendDataToDatabase(roomPhotoUrl:String, roomName: String,onSuccess: @escaping  () -> Void ){
        let newRoomId = Api.Room.REF_ROOMS.childByAutoId().key
        let newRoomReference = Api.Room.REF_ROOMS.child(newRoomId)
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        
        let timestamp = Int(Date().timeIntervalSince1970)
        print(timestamp)
        var dict = ["uid": currentUserId,
                    "roomPhotoUrl": roomPhotoUrl,
                    "roomName": roomName ,
                    "timestamp": timestamp,
                    "country":self.LModel.country,
                    "administrativeArea":self.LModel.administrativeArea,
                    "subAdministrativeArea":self.LModel.subAdministrativeArea,
                    "locality":self.LModel.locality,
                    "subLocality":self.LModel.subLocality,
                    "thoroughfare":self.LModel.thoroughfare,
                    "subThoroughfare":self.LModel.subThoroughfare] as [String : Any]
        
        newRoomReference.setValue(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            let myRoomsRef = Api.MyRooms.REF_MYROOMS.child(currentUserId).child(newRoomId)
            myRoomsRef.setValue(["timestamp":timestamp], withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            ProgressHUD.showSuccess("部屋を作成しました！")
            onSuccess()
        })
        
    }
    
    func clean_items(){
        self.roomNameTextField.text = nil
        self.photo.image = UIImage(named: "Placeholder-image")
        self.selectedImage = nil
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if  let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImage = image
            photo.image = image
            dismiss(animated: true,completion: nil)
        }
    }
  
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            LModel.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        LModel.ido = newLocation.coordinate.latitude
        LModel.keido = newLocation.coordinate.longitude
        reverseGeocode(latitude: LModel.ido!, longitude: LModel.keido!)
    }
    
    
    // 逆ジオコーディング処理(緯度・経度を住所に変換)
    func reverseGeocode(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemark, error) -> Void in
            let placeMark = placemark?.first
            if let country = placeMark?.country {
                //                print("\(country)")
                self.LModel.country = country
            }
            if let administrativeArea = placeMark?.administrativeArea {
                //                print("\(administrativeArea)")
                self.LModel.administrativeArea = administrativeArea
            }
            if let subAdministrativeArea = placeMark?.subAdministrativeArea {
                //                print("\(subAdministrativeArea)")
                self.LModel.subAdministrativeArea = subAdministrativeArea
            }
            
            if let locality = placeMark?.locality {
                //                print("\(locality)")
                self.LModel.locality = locality
            }
            if let subLocality = placeMark?.subLocality {
                //                print("\(subLocality)")
                self.LModel.subLocality = subLocality
            }
            if let thoroughfare = placeMark?.thoroughfare {
                //                print("\(thoroughfare)")
                self.LModel.thoroughfare = thoroughfare
            }
            if let subThoroughfare = placeMark?.subThoroughfare {
                 //                print("\(subThoroughfare)")
                self.LModel.subThoroughfare = subThoroughfare
            }
            
            self.LModel.address = self.LModel.country + self.LModel.administrativeArea + self.LModel.subAdministrativeArea
                + self.self.LModel.locality + self.LModel.subLocality + self.LModel.thoroughfare
            
            self.NowlocationLabel.text = self.LModel.address
//            print("住所　\(self.LModel.address)")
        })}
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if roomNameTextField.isFirstResponder {
            roomNameTextField.resignFirstResponder()
        }
    }

}
