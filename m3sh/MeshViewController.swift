//
//  MeshViewController.swift
//  SafetyM3sh
//
//  Created by Louis Moc on 2017-11-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let MeshControllerInstance = MeshViewController()

class MeshViewController : UIViewController, MCBrowserViewControllerDelegate {
    
    class var meshInstance : MeshViewController {
        return MeshControllerInstance
    }
    
    var data : NSMutableArray = []
    var browserViewController : MCBrowserViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        PeerManager.PeerManagerInstance.setupPeer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func browse(_ sender: Any) {
        var browserViewController = MCBrowserViewController(serviceType: "SafetyM3sh", session: (PeerManager.PeerManagerInstance.peer?.session)!)
        
        browserViewController.delegate = self
        
        present(browserViewController, animated: true) {
        }
    }
    
    // MCBrowserViewController Delegate
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController!){
        browserViewController.dismiss(animated: true) {
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController!){
        browserViewController.dismiss(animated: true,completion: {
        })
    }
    
    @IBAction func startAdvertising(_ sender: Any) {
        PeerManager.PeerManagerInstance.start()
    }
        
    @IBAction func stopAdvertising(_ sender: Any) {
        PeerManager.PeerManagerInstance.stop()
    }
}

