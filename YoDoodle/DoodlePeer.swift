//
//  DoodlePeer.swift
//  YoDoodle
//
//  Created by Phillip Fiedler on 12/28/17.
//  Copyright © 2017 Phillip Fiedler. All rights reserved.
//
//  https://www.ralfebert.de/tutorials/ios-swift-multipeer-connectivity/

import UIKit
import Foundation
import MultipeerConnectivity

class DoodlePeer: NSObject
{
    private var peerID: MCPeerID!
    private let myServiceName = "yodoodle"
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : DoodlePeerDelegate?
    
    
    override init()
    {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: myServiceName)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: myServiceName)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    deinit
    {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    
    func send(doodleMark : DoodleMark)
    {
        if session.connectedPeers.count > 0
        {
            do
            {
                let doodleMarkString = doodleMark.toString
                try self.session.send(doodleMarkString.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error
            {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
}


extension DoodlePeer : MCNearbyServiceAdvertiserDelegate
{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
    {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}


extension DoodlePeer : MCNearbyServiceBrowserDelegate
{
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error)
    {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}


extension DoodlePeer : MCSessionDelegate
{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.addDoodleMark(manager: self, doodleMarkString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}


protocol DoodlePeerDelegate
{
    func connectedDevicesChanged(manager : DoodlePeer, connectedDevices: [String])
    func addDoodleMark(manager : DoodlePeer, doodleMarkString: String)
}

