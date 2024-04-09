//
//  workoutView.swift
//  watchApp
//
//  Created by Shimmy on 4/4/24.
//

import SwiftUI
import WatchKit


struct WorkoutView: View {

    @State var tabSelection = 2
    @StateObject var watchVM = WatchSessionDelegate.shared
    @StateObject var workoutManager = WorkoutManager.shared
    
    var body: some View {
        TabView(selection: $tabSelection) {
            WorkoutControlsView().tag(1)
            workoutProcessView.tag(2)
            NowPlayingView().tag("now Playing")
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            workoutManager.startWorkout(workoutType: .functionalStrengthTraining)
        }
    }
    
    
    var workoutProcessView : some View {
        VStack {
            
            TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date())) { context in
                    HStack(alignment: .center) {
                        Image(systemName: "flame.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.red)
                            .frame(width: 10 , height: 10)
                        Text(Measurement(value: workoutManager.activeEnergy, unit: UnitEnergy.kilocalories)
                          .formatted(.measurement(width: .abbreviated, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))))
                              .font(.system(size: 10))
                        Spacer()
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.red)
                            .frame(width: 10, height: 10)
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
                            .font(.system(size: 10))
                        Spacer()
                        ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime ?? 0, showSubseconds: context.cadence == .live)
                            .foregroundStyle(.yellow)
                    }
                    .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ignoresSafeArea(edges: .bottom)
                    .scenePadding()
                    .frame(alignment: .center)
                
            }
            
            Text(watchVM.exercises.isEmpty ? "" : watchVM.exercises[watchVM.exerciseIndex].name )
            Text("\(watchVM.setInfoCompleteList[watchVM.exerciseIndex] + 1) set")
            
            
            
            Button {
                watchVM.nextWorkout()
            } label: {
                Text("다음운동")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    
            }.frame(width: 40, height: 10)
            Spacer()

        }
    }
    
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
    }
}
