// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let workoutData = try? JSONDecoder().decode(WorkoutData.self, from: jsonData)

import Foundation

// MARK: - WorkoutData
struct WorkoutData: Codable {
    var command: String
    var watchModel: WatchModel
}

// MARK: - WatchModel
struct WatchModel: Codable {
    var exerciseIndex: Int
    var maxExerciseIndex: Int
    var setInfoCompleteList: [Int]
    var maxSetInfoList: [Int]
    var exercises: [Exercise]
    var totalTime: Int
    var groupCounts: Dictionary<Int, Int>
}

// MARK: - Exercise
struct Exercise: Codable {
    let workoutPlanID: Int
    var setInfo: [SetInfo]
    let name: String
    let trackingFieldID: Int
    let isVideoRecord: Bool

    enum CodingKeys: String, CodingKey {
        case workoutPlanID = "workoutPlanId"
        case setInfo, name
        case trackingFieldID = "trackingFieldId"
        case isVideoRecord
    }
}

// MARK: - SetInfo
struct SetInfo: Codable {
    let index: Int
    var reps, weight: Int
    var seconds: Int?
}
