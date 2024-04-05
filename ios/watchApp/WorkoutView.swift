//
//  workoutView.swift
//  watchApp
//
//  Created by Shimmy on 4/4/24.
//

import SwiftUI

struct WorkoutView: View {

  @StateObject var watchVM = WatchSessionDelegate.shared
  
  var body: some View {
      
      VStack {
            
          Text(watchVM.exercises.isEmpty ? "" : watchVM.exercises[watchVM.exerciseIndex].name )
          Text("\(watchVM.setInfoCompleteList[watchVM.exerciseIndex] + 1) set")
          Button {
              watchVM.nextWorkout()
          } label: {
              Text("다음운동")
          }

      }
      
    
  }

}
