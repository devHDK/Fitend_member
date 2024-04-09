//
//  WorkoutControllView.swift
//  watchApp
//
//  Created by Shimmy on 4/8/24.
//

import SwiftUI
import WatchKit

struct WorkoutControlsView: View {
    @StateObject var workoutManager = WorkoutManager.shared
    var body: some View {
        VStack {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
                .font(.title2)
                Text("End")
            }
            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                }
                .tint(.yellow)
                .font(.title2)
                Text(workoutManager.running ? "Pause" : "Resume")
            }
        }
    }
}
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlsView()
    }
}
