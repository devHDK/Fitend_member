//
//  workoutView.swift
//  watchApp
//
//  Created by Shimmy on 4/4/24.
//

import SwiftUI

struct WorkoutView: View {

    @StateObject var viewModel = WatchSessionDelegate.shared

  @State var exercises: [Exercise] = []
  @State var exerciseIndex = 0

  
    
  var body: some View {
      
      VStack {
            
          Text(exercises.isEmpty ? "없네..." : exercises[exerciseIndex].name )
          Text("\(exerciseIndex)")
      }.onAppear(){
          
          print(viewModel.data?.command)
          
          self.exercises = viewModel.exercises
          self.exerciseIndex = viewModel.exerciseIndex
      }
      
    
  }

}
