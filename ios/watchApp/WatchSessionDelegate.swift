//
//  WatchSessionDelegate.swift
//  fitend Watch App
//
//  Created by Shimmy on 3/11/24.
//

import Foundation
import SwiftUI
import WatchConnectivity

class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    
    private let session = WCSession.default
    
    @Published var reachable = false
    @Published var context = [String: Any]()
    @Published var receivedContext = [String: Any]()
    @Published var log = [String]()
        
    
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    
    public func refresh(){
        reachable = session.isReachable
        context = session.applicationContext
        receivedContext = session.receivedApplicationContext
    }
    
    public func sendMessage(_ message: [String:Any]){
         session.sendMessage(message, replyHandler: nil)
        log.append("Send message: \(message)")
    }
    
    public func updateApplicationContext(_ context: [String: Any]){
        try? session.updateApplicationContext(context)
        log.append("Sent context: \(context)")
    }
    
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            refresh()
    }
        
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
            DispatchQueue.main.async { self.log.append("Received message: \(message)") }
    }
        
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
          DispatchQueue.main.async { self.log.append("Received context: \(applicationContext)") }
    }

   
    
}
