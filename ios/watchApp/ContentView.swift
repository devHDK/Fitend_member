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
    @StateObject var session = WatchSessionDelegate();
    @StateObject var data = ActivityData()
    @EnvironmentObject var workoutManager: WorkoutManager
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    @State private var heartRate = 0
    @State var showingBreatheSheet = false
    
    @State private var animationScale: CGFloat = 1.0
    private let animationDuration: Double = 0.6 // 기본 애니메이션 주기 (초 단위)
    @State private var animationTimer: Timer? = nil
    
    var body: some View {
        TabView(selection: $tabSelection) {
            workoutPreview
                .tag(1)
            heartRateView
                .tag(2)
            activityView
                .tag(3)
            
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear(){
            workoutManager.requestAuthorisation()
        }
        .sheet(isPresented: $session.shouldNavigate) {
            workoutView()
        }
    }

    var activityView: some View {
            
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

    var heartRateView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(Font.custom("Heart", size: CGFloat(60)))
                    .frame(width: 60, height: 60)
                Spacer()
            }
            .scaleEffect(animationScale)
            .animation(Animation.easeIn(duration: 60/Double(heartRate)).repeatForever(autoreverses: true))
            .task {
                startHeartRateQuery(quantityTypeIdentifier: .heartRate)
                startAnimationLoop()
            }
            HStack {
                Spacer()
                Text("\(heartRate) BPM")
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
        .onDisappear {
                    stopAnimationLoop()
                }
            
    }
    
    var workoutPreview: some View {
        VStack {
            if session.data != nil {
                Text("\(session.data!.command)")
            }
            else {
                Text("앱에서 시작해 주세요")
            }
        }
        .navigationTitle("오늘의 운동")
            
    }
    
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
                
                self.heartRate = Int(lastHeartRate)
            }
        }
    
    private func startAnimationLoop() {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 60/Double(heartRate), repeats: true) { _ in
                withAnimation {
                    animationScale = animationScale == 1.0 ? 1.2 : 1.0
                }
            }
            
            // 타이머를 RunLoop에 추가
            RunLoop.current.add(animationTimer!, forMode: .common)
        }
    
    private func stopAnimationLoop() {
            animationTimer?.invalidate()
            animationTimer = nil
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
