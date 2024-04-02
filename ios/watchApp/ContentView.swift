//
//  ContentView.swift
//  fitend Watch App
//
//  Created by Shimmy on 3/11/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    @State var tabSelection = 1
    @StateObject var data = ActivityData()
    @ObservedObject var session = WatchSessionDelegate();
    @EnvironmentObject var workoutManager: WorkoutManager
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    @State private var value = 0
    @State var showingBreatheSheet = false
    
    
    var body: some View {
        TabView(selection: $tabSelection) {
            activity
                .tag(1)
            heartRate
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear(){
            workoutManager.requestAuthorisation()
        }
    }

    var activity: some View {
            
            VStack {
                ActivityRings(data: data, healthStore: workoutManager.healthStore)
                Text("\(data.energyData)")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.red)
                    .privacySensitive()
                Text("\(data.exerciseData)")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.green)
                    .privacySensitive()
                Text("\(data.standData)")
                    .bold()
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
                    .privacySensitive()
            }.navigationTitle("")
            
    }

    var heartRate: some View {
        VStack {
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Button(action: {startHeartRateQuery(quantityTypeIdentifier: .heartRate)}) {
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(Font.custom("Heart", size: CGFloat(60)))
                        
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                
                Spacer()
            }
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Text("\(value) BPM")
                    .bold()
                    .font(.system(.title, design: .rounded))
                    .padding()
                    .privacySensitive()
                Spacer()
            }
            .padding(.bottom)
            Spacer()
        }
        .navigationTitle("Heart Rate")
            
    }
    
//    func calulateAnimation(heartRate: Int) -> CGFloat {
//      // Calculate heart rate animation factor
//      let value1 = Double(heartRate) / 100
//      var value = 2.0 * Double(time) * Double.pi * value1
//      let heartRateAnimationFactor = 0.2 * sin(value)
//      // Combine constant and animation factor
//      let scale = 1.0 + heartRateAnimationFactor
//      return scale
//    }
    
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
            
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                query, samples, deletedObjects, queryAnchor, error in
                
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
                
            self.process(samples, type: quantityTypeIdentifier)

            }
            
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            
            query.updateHandler = updateHandler
            healthStore.execute(query)
        }
    
    func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
            var lastHeartRate = 0.0
            
            for sample in samples {
                if type == .heartRate {
                    lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                }
                
                self.value = Int(lastHeartRate)
            }
        }

}

class ActivityData: ObservableObject {
    @Published var energyData = ""
    @Published var exerciseData = ""
    @Published var standData = ""
}

#Preview {
    
//    var workoutManager: WorkoutManager
//    ContentView( workoutManager: workoutManager)
    Text("FITEND")
}

struct ActivityRings: WKInterfaceObjectRepresentable {
    @ObservedObject var data: ActivityData
    let healthStore: HKHealthStore
    func makeWKInterfaceObject(context: Context) -> some WKInterfaceObject {
        let rings = WKInterfaceActivityRing()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            DispatchQueue.main.async {
                let standUnit = HKUnit.count()
                let exerciseUnit = HKUnit.minute()
                let energyUnit = HKUnit.kilocalorie()
                let energy = summaries?.first?.activeEnergyBurned.doubleValue(for: energyUnit)
                let exercise = summaries?.first?.appleExerciseTime.doubleValue(for: exerciseUnit)
                let stand = summaries?.first?.appleStandHours.doubleValue(for: standUnit)
                
                data.energyData = "\(energy?.rounded(.towardZero) ?? Double(0.0)) \(energyUnit)"
                data.exerciseData = "\(exercise?.rounded(.towardZero) ?? Double(0.0)) 분"
                data.standData = "\(stand?.rounded(.towardZero) ?? Double(0.0)) 번"
                rings.setActivitySummary(summaries?.first, animated: true)
                
            }
        }
        healthStore.execute(query)
        return rings
    }
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {
        
    }
}
