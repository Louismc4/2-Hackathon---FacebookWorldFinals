//
//  Peer.swift
//  SafetyM3sh
//
//  Created by Louis Moc on 2017-11-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

var from_Peer : MCPeerID?

class Peer : NSObject, MCSessionDelegate {
    
    var peerID : MCPeerID
    var session : MCSession
    var advertiser : MCAdvertiserAssistant
    
    init(peerID : MCPeerID, session : MCSession, advertiser : MCAdvertiserAssistant){
        self.peerID = peerID
        self.session = session
        self.advertiser = advertiser
        
        super.init()
        self.session.delegate = self
    }
    
    func sessionSendData(_ data: Data)
    {
        var error: NSError?
        
        do {
            try self.session.send(data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print(error)
        }
    }
    
    func advertiserStart(){
        advertiser.start()
    }
    
    func advertiserStop(){
        advertiser.stop()
    }
    
    //--------------------------MCSession Delegate Functions
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        print("didReceiveData")
        var dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String : Any]
        if let peers = (dictionary as! NSDictionary)["peers"] as? String {
            if let idVal = UserDefaults.standard.object(forKey: "id") as? String {
                if peers.contains(idVal){
                    print("BAIL OUT")
                    return
                }
            }
        }
        if let resp = (dictionary as! NSDictionary)["fb_id"] as? String {
            if resp == UserDefaults.standard.object(forKey: "id") as? String {
                print("yuh1")
                if let respMsg = (dictionary as! NSDictionary)["msg"] as? String {
                    print("yuh2")
                    LocationViewController.LocationControllerInstance.show(msg : respMsg)
                }
            } else {
                if(InternetManager.internetManager.isInternetAvailable()){
                    print("yuh3")
                    LocationViewController.LocationControllerInstance.safetyPost(params: dictionary!)
                } else {
                    print("yuh4")
                    from_Peer = peerID
                    if let id = UserDefaults.standard.object(forKey: "id") as? String {
                        print(dictionary)
//                        if let idVal = dictionary!["fb_id"] as? String {
                            //visualDict["name"] = name
//                            if let long = dictionary!["longitude"] as? Double{
//                                if let lat = dictionary!["latitude"] as? Double{
//                                    if let alt = dictionary!["altitude"] as? Double{
//                                        visualDict[idVal]!["altitude"] = alt
//                                        visualDict[idVal]!["longitude"] = long
//                                        visualDict[idVal]!["latitude"] = lat
//                                    }
//                                }
//                            }
//                        }
                        if let dataVal = dictionary!["peers"] as? String {
                            dictionary!["peers"]  = dataVal + id + ","
                        }
                    }
                    PeerManager.PeerManagerInstance.sendData(data : NSKeyedArchiver.archivedData(withRootObject: dictionary))
                }
            }
        }
    }
    
    // Remote peer changed state.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
        print("didChangeState")
    }
    
    // Received a byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        print("didReceivestream")
    }
    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        print("didStartReceivingResourceWithName " + resourceName)
    }
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?){
        print("didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Swift.Void){
        print(certificateHandler(true))
    }
}

