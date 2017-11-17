//
//  LocationViewController.swift
//  SafetyM3sh
//
//  Created by Louis Moc on 2017-11-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKLoginKit

let LocationController = LocationViewController()

class LocationViewController : UIViewController, CLLocationManagerDelegate, FBSDKLoginButtonDelegate {
    
    class var LocationControllerInstance : LocationViewController {
        return LocationController
    }

    let locationManager : CLLocationManager = CLLocationManager()

    let loginButton : FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email"]
        return button
    }()
    
    @IBOutlet weak var safetySegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return
            case .authorizedAlways, .authorizedWhenInUse:
                //Get best location, request authorization, update location in the background, update location when moved (in meters), start updating
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.distanceFilter = 1
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(1, forKey: "status")
        safetySegment.selectedSegmentIndex = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude:
            locations.last!.coordinate.longitude)
        let altitude = locations.last!.altitude
        
        if let auth_Token = UserDefaults.standard.object(forKey: "token") as? String {
            if(auth_Token != ""){
                print("dsdssd")
                if let id = UserDefaults.standard.object(forKey: "id") as? String {
                    if(id != ""){
                        if let status = UserDefaults.standard.object(forKey: "status") as? Int {
                            print("SAADSADDADAS")
                            var final_data = ["status" : status, "peers" : "", "fb_id" : id, "token" : auth_Token, "name" : UserDefaults.standard.object(forKey: "username"), "latitude" : currentLocation.latitude, "longitude" : currentLocation.longitude, "altitude" : altitude]
                            let dataVal = ""
                            final_data["peers"] = dataVal + id + ","
                            print(final_data)
                            if(InternetManager.internetManager.isInternetAvailable()){
                                print("LOL")
                                self.safetyPost(params: final_data)
                            } else {
                                print("LOL2")
                                PeerManager.PeerManagerInstance.sendData(data : NSKeyedArchiver.archivedData(withRootObject: final_data))
                            }
                        }
                    }
                }
            }
        }
        locationManager.stopUpdatingLocation()
    }
        
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        UserDefaults.standard.set(0, forKey: "fetch")
        self.performSegue(withIdentifier: "unwindtologin", sender: self)
    }
        
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    @IBAction func setSafety(_ sender: Any) {
        switch((sender as AnyObject).selectedSegmentIndex){
        case 0:
            print("wtf")
            
             UserDefaults.standard.set(0, forKey: "status")
            break
        case 1:
            print("wtf2")
            UserDefaults.standard.set(1, forKey: "status")
            break
        default :
            break
        }
    }
    
    @IBAction func postInfo(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    func safetyPost(params: [String:Any]) {
        var request = URLRequest(url: URL(string: "https://safetym3sh.herokuapp.com/facebookpost")!)
        request.httpMethod = "POST"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error)")
                self.show(msg : "\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let resp = (jsonResponse as! NSDictionary)["id"] as? String {
                if resp == UserDefaults.standard.object(forKey: "id") as? String {
                    if let respMsg = (jsonResponse as! NSDictionary)["msg"] as? String {
                        DispatchQueue.main.async() {
                            let alert = UIAlertController(title: "Alert", message: respMsg, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    var data = ["fb_id" : (jsonResponse as! NSDictionary)["fb_id"] as? String, "msg" : (jsonResponse as! NSDictionary)["msg"] as? String, "peers" : ""]
                    if let idVal = UserDefaults.standard.object(forKey: "id") as? String {
                        if let dataVal = data["peers"] as? String {
                            data["peers"] = dataVal + idVal + ","
                        }
                    }
                    PeerManager.PeerManagerInstance.sendData(data : NSKeyedArchiver.archivedData(withRootObject: data))
                }
            }
        }
        task.resume()
    }
    
//    @IBAction func send(_ sender: Any) {
//        PeerManager.PeerManagerInstance.sendData(data : NSKeyedArchiver.archivedData(withRootObject: ["keee" : 233]))
//        if(InternetManager.internetManager.isInternetAvailable()){
//            // Define server side script URL
//            let scriptUrl = "https://facebooklouismoc-louismc4.c9users.io/facebookget"
//            // Create NSURL Ibject
//            let myUrl = NSURL(string: scriptUrl);
//
//            // Creaste URL Request
//            let request = NSMutableURLRequest(url:myUrl! as URL);
//
//            // Set request HTTP method to GET. It could be POST as well
//            request.httpMethod = "GET"
//            // Excute HTTP Request
//            let task = URLSession.shared.dataTask(with: request as URLRequest) {
//                data, response, error in
//
//                // Check for error
//                if error != nil
//                {
//                    print("error=\(error)")
//                    return
//                }
//                // Print out response string
//                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                print("responseString = \(responseString)")
//
//
//                // Convert server json response to NSDictionary
//                do {
//                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
//
//                        // Print out dictionary
//                        print(convertedJsonIntoDict)
//
//                        // Get value by key
//                        //                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
//                        //                    print(firstNameValue!)
//
//                        PeerManager.PeerManagerInstance.sendData(data : NSKeyedArchiver.archivedData(withRootObject: ["keee" : 233]))
//
//                    }
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//
//            }
//
//            task.resume()
//        }
//    }
    func show(msg : String){
        DispatchQueue.main.async() {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = msg
            alert.addButton(withTitle: "Okay")
            alert.show()
        }
    }
}
