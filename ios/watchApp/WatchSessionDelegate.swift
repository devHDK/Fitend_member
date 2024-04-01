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
        //            refresh()
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            // jsonData를 사용하여 WorkoutData 디코딩
            let workoutData = try JSONDecoder().decode(WorkoutData.self, from: jsonData)
            
            print(workoutData.watchModel)
            print(workoutData.command)
            
            DispatchQueue.main.async {
                // 메인 스레드에서 UI 업데이트 등의 작업 수행
                self.log.append("Received command: \(workoutData.command)")
            }
        } catch {
            print("JSON 디코딩 실패: \(error)")
        }
        
        DispatchQueue.main.async {
            // self.log.append("Received message: \(message)")
        }
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.log.append("Received context: \(applicationContext)") }
    }
    
#if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif
    
    
}
