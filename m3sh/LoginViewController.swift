//
//  LoginViewController.swift
//  SafetyM3sh
//
//  Created by Louis Moc on 2017-11-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKLoginKit
import SystemConfiguration

class LoginViewController : UIViewController, FBSDKLoginButtonDelegate {
    
    let locationManager : CLLocationManager = CLLocationManager()
    
    let loginButton : FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email"]
        button.publishPermissions = ["publish_actions"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestAlwaysAuthorization()
        
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let token = FBSDKAccessToken.current() {
            if let value = UserDefaults.standard.object(forKey: "token") as? String {
                self.performSegue(withIdentifier: "seguetomain", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(InternetManager.internetManager.isInternetAvailable()){
            let value = UserDefaults.standard.object(forKey: "fetch") as? Int ?? 0
            if value == 0 {
                fetchProfile()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        UserDefaults.standard.set(0, forKey: "fetch")
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func fetchProfile() {
        let params = ["fields": "first_name, last_name"]
        //picture.type(large)
        FBSDKGraphRequest(graphPath: "me", parameters: params).start { (connection, result, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            var fb_id = ""
            var fb_email = ""
            var fb_name = ""
            
            if let id = (result! as? NSDictionary)?["id"] as? String{
                print(id)
                fb_id = id
            } else {
                return
            }
            
            if let first_name = (result as? NSDictionary)?["first_name"] as? String {
                if let last_name = (result as? NSDictionary)?["last_name"] as? String {
                    print(first_name + " " + last_name)
                    fb_name = first_name + " " + last_name
                }
            }
            
            if let auth_Token = FBSDKAccessToken.current().tokenString as? String {
                if(auth_Token != ""){
                    UserDefaults.standard.set(fb_id, forKey: "id")
                    UserDefaults.standard.set(fb_email, forKey: "email")
                    UserDefaults.standard.set(fb_name, forKey: "username")
                    UserDefaults.standard.set(auth_Token, forKey: "token")
                    UserDefaults.standard.set(1, forKey: "status")
                    let data = ["fb_id" : fb_id, "name": fb_name, "token": auth_Token, "address" : "", "altitude" : 0, "date" : 0, "latitude" : 0, "longitude" : 0, "status" : 1] as [String : Any]
                    self.facebookHTTPPost(params: data)
                }
            }
        }
    }
    
    func facebookHTTPPost(params: [String:Any]) {
        var request = URLRequest(url: URL(string: "https://safetym3sh.herokuapp.com/facebookInit")!)
        request.httpMethod = "POST"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params)
            request.httpBody = jsonData
        } catch {
            print(error.localizedDescription)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }

            let responseString = String(data: data, encoding: .utf8)

            print("responseString = \(responseString)")

        }
        task.resume()
        DispatchQueue.main.async {
            UserDefaults.standard.set(1, forKey: "fetch")
            self.performSegue(withIdentifier: "seguetomain", sender: self)
        }
    }
    
    //Unwind from the other page
    @IBAction func unwindLogout(unwindSegue : UIStoryboardSegue){
        print("Unwinded from something!")
    }
}
