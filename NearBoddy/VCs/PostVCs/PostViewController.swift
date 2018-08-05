//
//  PostViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import CoreLocation

class PostViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var NowlocationLabel:UILabel!

    var LModel:LocationModel = LocationModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        catchLocationData()
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "roomsVC" {
            let roomsVC = segue.destination as! RoomsViewController
            self.LModel.address = self.LModel.country + self.LModel.administrativeArea + self.LModel.subAdministrativeArea
                + self.LModel.locality + self.LModel.subLocality + self.LModel.thoroughfare
            roomsVC.adress = self.LModel.address
        }
    }

    @IBAction func goToRoomVC_Btn(){
        if CLLocationManager.locationServicesEnabled(){
            LModel.locationManager.stopUpdatingLocation()
            
        }
        
        self.performSegue(withIdentifier: "roomsVC", sender: nil)
        
    }
    
    @IBAction func goToCreateRoomVC_Btn(){
        if CLLocationManager.locationServicesEnabled(){
            LModel.locationManager.stopUpdatingLocation()
            
        }
        
        self.performSegue(withIdentifier: "createRoomVC", sender: nil)
        
    }
    
    @IBAction func goToCreatePostVC_Btn(){
        if CLLocationManager.locationServicesEnabled(){
            LModel.locationManager.stopUpdatingLocation()
            
        }
        
        self.performSegue(withIdentifier: "createPostVC", sender: nil)
    }
    
// 以下、 位置情報メソッド。
    func catchLocationData(){

        if CLLocationManager.locationServicesEnabled() {
            LModel.locationManager = CLLocationManager()
            LModel.locationManager.delegate = self
            LModel.locationManager.startUpdatingLocation()
        }
    }

    /*******************************************

     位置情報取得に関するアラートメソッド

     ********************************************/


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

    /**********************************

      位置情報が更新されるたびに呼ばれるメソッド

     ***********************************/

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

}

