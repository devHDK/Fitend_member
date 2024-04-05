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
    
       static let shared = WatchSessionDelegate()
       
    
       private let session = WCSession.default
       
       @Published var reachable = false
       @Published var shouldNavigate = false
       @Published var context = [String: Any]()
       @Published var receivedContext = [String: Any]()
       @Published var data: WorkoutData?
       
       //실제 사용할 데이터
       @Published var exercises: [Exercise] = []
       @Published var exerciseIndex: Int = 0
       @Published var maxExerciseIndex: Int = 0
       @Published var setInfoCompleteList: [Int] = []
       @Published var maxSetInfoList: [Int] = []
       @Published var totalTime: Int = 0
       @Published var groupCounts: Dictionary<Int, Int>?
    
       private override init() {
           super.init()
           
           session.delegate = self
           session.activate()
       }
       
       // 다른 메서드들은 동일
       
       public func refresh() {
           reachable = session.isReachable
           context = session.applicationContext
           receivedContext = session.receivedApplicationContext
       }
       
       public func sendMessage(_ message: [String: Any]) {
           session.sendMessage(message, replyHandler: nil)
       }
       
       public func updateApplicationContext(_ context: [String: Any]) {
           try? session.updateApplicationContext(context)
       }
    
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //            refresh()
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            // jsonData를 사용하여 WorkoutData 디코딩
            let workoutData = try JSONDecoder().decode(WorkoutData.self, from: jsonData)
            
            
            DispatchQueue.main.async {
                
                // 메인 스레드에서 UI 업데이트 등의 작업 수행
                self.data = workoutData
                self.shouldNavigate = true
                self.exercises = workoutData.watchModel.exercises
                self.exerciseIndex = workoutData.watchModel.exerciseIndex
                self.maxExerciseIndex = workoutData.watchModel.maxExerciseIndex
                self.setInfoCompleteList = workoutData.watchModel.setInfoCompleteList
                self.maxSetInfoList = workoutData.watchModel.maxSetInfoList
                self.totalTime = workoutData.watchModel.totalTime
                self.groupCounts = workoutData.watchModel.groupCounts
                
                
                print("exerciseIndex \(self.exerciseIndex)")
                print("groupCount \(String(describing: self.groupCounts))")
                
            }
            
        } catch {
            
            print("JSON 디코딩 실패: \(error)")
            
        }
        
        DispatchQueue.main.async {
            // self.log.append("Received message: \(message)")
        }
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {}
    }
    
    public func nextWorkout(){
        if self.setInfoCompleteList[self.exerciseIndex] < self.maxSetInfoList[self.exerciseIndex]{
            
            self.setInfoCompleteList[self.exerciseIndex] += 1
            self.data?.watchModel.setInfoCompleteList[self.exerciseIndex] += 1
            
            do {
                
                let json = try JSONEncoder().encode(self.data)
                let dict: Dictionary<String,Any> = try JSONSerialization.jsonObject(with: json) as! Dictionary<String, Any>
                
                sendMessage(dict)
                
            }catch{
                
            }
            
        }
        
        
    }
    
#if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif
    
    
}
