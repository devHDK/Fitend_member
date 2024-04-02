//
//  fitendApp.swift
//  fitend Watch App
//
//  Created by Shimmy on 3/11/24.
//

import SwiftUI

@main
struct fitend_Watch_AppApp: App {
    
    @StateObject var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                ContentView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }
        
    }
}
