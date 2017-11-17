//
//  VisualViewController.swift
//  SafetyM3sh
//
//  Created by Louis Moc on 2017-11-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

var visualDict = [String:[String:Any]]()

class VisualViewController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(InternetManager.internetManager.isInternetAvailable()){
            
            let urlString = URL(string: "https://safetym3sh.herokuapp.com/facebookget")
            if let url = urlString {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        print(error)
                    } else {
                        if let data = data {
                            
                            if let strData = String(data: data, encoding: String.Encoding.utf8) {
                                let parts = strData.components(separatedBy: ",")
                                print(parts)
                                let mid = Int(floor(Double(parts.count / 2)))
                                
                                for i in (0..<parts.count-1) where i % 2 == 0 {
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(parts[i])!, longitude: Double(parts[i+1])!)
                                    self.mapView.addAnnotation(annotation)
                                }
                            }
                            
                        }
                    }
                }
                task.resume()
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 11.12, longitude: 12.11)
        mapView.addAnnotation(annotation)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

