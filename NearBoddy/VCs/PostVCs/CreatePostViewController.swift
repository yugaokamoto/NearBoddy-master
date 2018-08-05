//
//  CreatePostViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import ProgressHUD

class CreatePostViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var NowlocationLabel:UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    
    
    var LModel:LocationModel = LocationModel()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        catchLocationData()
    }

    @IBAction func sharePost_touchUpInside(){
        reverseGeocode(latitude: LModel.ido!, longitude: LModel.keido!)
        ProgressHUD.show("投稿中です...")
        sendDataToDatabase()
    }
    
    func sendDataToDatabase() {
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId)
        guard let currentUser = Auth.auth().currentUser else  {
            return
        }
        let currentUserId = currentUser.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        newPostReference.setValue(["uid": currentUserId ,"caption": captionTextView.text!,"location":NowlocationLabel.text!,"timestamp":timestamp], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            let myPostsRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostsRef.setValue(["timestamp":timestamp], withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            self.clean() 
            ProgressHUD.showSuccess("Success")
            self.tabBarController?.selectedIndex = 0
        })
    }
    
    func clean() {
        self.captionTextView.text = ""
    }
    
    func catchLocationData(){
        
        if CLLocationManager.locationServicesEnabled() {
            LModel.locationManager = CLLocationManager()
            LModel.locationManager.delegate = self
            LModel.locationManager.startUpdatingLocation()
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
                print("\(subThoroughfare)")
                self.LModel.subThoroughfare = subThoroughfare
            }
            
            self.LModel.address = self.LModel.country + self.LModel.administrativeArea + self.LModel.subAdministrativeArea
                + self.self.LModel.locality + self.LModel.subLocality + self.LModel.thoroughfare
            
            self.NowlocationLabel.text = self.LModel.address
            print("住所　\(self.LModel.address)")
            
        })}
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if captionTextView.isFirstResponder {
            captionTextView.resignFirstResponder()
        }
    }

}
