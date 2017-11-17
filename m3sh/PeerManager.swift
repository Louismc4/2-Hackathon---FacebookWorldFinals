//
//  PeerManager.swift
//  SafetyM3sh
//
//  Created by Louis Moc on 2017-11-16.
//  Copyright © 2017 Louis Moc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let PeerManagerSharedInstance = PeerManager()

class PeerManager {
    
    var peer : Peer?
    
    class var PeerManagerInstance : PeerManager {
        return PeerManagerSharedInstance
    }
    
    func setupPeer(){
        var peerID : MCPeerID
        if let value = UserDefaults.standard.object(forKey: "username") as? String {
            peerID = MCPeerID(displayName: value)
        } else {
            peerID = MCPeerID(displayName: UIDevice.current.name)
        }
        let session : MCSession =  MCSession(peer: peerID)
        let advertiser : MCAdvertiserAssistant = MCAdvertiserAssistant(serviceType : "SafetyM3sh", discoveryInfo : nil, session : session)
        
        self.peer = Peer(peerID: peerID, session: session, advertiser: advertiser)
    }
    
    func sendData(data : Data){
        self.peer?.sessionSendData(data)
    }
    
    func start(){
        self.peer?.advertiserStart()
    }
    
    func stop(){
        self.peer?.advertiserStop()
    }
}
