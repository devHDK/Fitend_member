// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let workoutData = try? JSONDecoder().decode(WorkoutData.self, from: jsonData)

import Foundation

// MARK: - WorkoutData
struct WorkoutData: Codable {
    let command: String
    let watchModel: WatchModel
}

// MARK: - WatchModel
struct WatchModel: Codable {
    let exerciseIndex, maxExerciseIndex: Int
    let setInfoCompleteList, maxSetInfoList: [Int]
    let exercises: [Exercise]
}

// MARK: - Exercise
struct Exercise: Codable {
    let workoutPlanID: Int
    let setInfo: [SetInfo]
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
    let index, reps, weight: Int
    let seconds: Int?
}
