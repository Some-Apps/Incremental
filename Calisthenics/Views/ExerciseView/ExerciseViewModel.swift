//
//  ExerciseViewModel.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/6/23.
//

import AlertToast
import CoreData
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData

class ExerciseViewModel: ObservableObject {
    static let shared = ExerciseViewModel(stopwatchViewModel: StopwatchViewModel.shared)
    
    @Published var exercise: Exercise? = nil
    @Published var difficulty: Difficulty = .medium
    @Published var isLoading = true

    @AppStorage("randomExercise") var randomExercise: String = ""
    @AppStorage("easyType") var easyType = "Increment"
    @AppStorage("easyIncrement") var easyIncrement = 0.5
    @AppStorage("easyPercent") var easyPercent = 5.0
    @AppStorage("mediumType") var mediumType = "Increment"
    @AppStorage("mediumIncrement") var mediumIncrement =  0.1
    @AppStorage("mediumPercent") var mediumPercent = 1.0
    @AppStorage("hardType") var hardType = "Increment"
    @AppStorage("hardIncrement") var hardIncrement = -1.0
    @AppStorage("hardPercent") var hardPercent = -5.0

    @Environment(\.modelContext) private var modelContext

    let stopwatchViewModel: StopwatchViewModel
    
    init(stopwatchViewModel: StopwatchViewModel) {
        self.stopwatchViewModel = stopwatchViewModel
    }

    func requestAuthorization() {
        let healthStore = HKHealthStore()
        let typesToShare: Set<HKSampleType> = [HKObjectType.workoutType()]
        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType(), HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func saveWorkout(exerciseType: HKWorkoutActivityType, startDate: Date, endDate: Date, duration: TimeInterval) {
        let healthStore = HKHealthStore()

        let workout = HKWorkout(activityType: exerciseType,
                                start: startDate,
                                end: endDate,
                                workoutEvents: nil,
                                totalEnergyBurned: nil,
                                totalDistance: nil,
                                metadata: nil)

        healthStore.save(workout) { (success, error) in
            if let error = error {
                print("Error saving workout: \(error.localizedDescription)")
            } else {
                print("Successfully saved workout")
            }
        }
    }
    
    func createLog(difficulty: Difficulty, lastExercise: Exercise) {
        let newLog = Log(duration: Int16(exactly: stopwatchViewModel.seconds)!, id: UUID(), reps: Int16(exactly: lastExercise.currentReps.rounded(.down))!, timestamp: Date(), units: lastExercise.units, exercises: lastExercise)
        
        newLog.id = UUID()
        newLog.duration = Int16(exactly: stopwatchViewModel.seconds)!
        newLog.reps = Int16(exactly: lastExercise.currentReps.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = lastExercise.units
        
        print("LOG: \(difficulty)")

        // why isn't this actually saving the difficulty?
        lastExercise.difficulty = difficulty.rawValue
//        lastExercise.addToLogs(newLog)

        switch difficulty {
        case .easy:
            if easyType == "Increment" {
                lastExercise.currentReps += easyIncrement
            } else {
                lastExercise.currentReps *= (easyPercent/100 + 1)
            }
        case .medium:
            if mediumType == "Increment" {
                lastExercise.currentReps += mediumIncrement
            } else {
                lastExercise.currentReps *= (mediumPercent/100 + 1)
            }
        case .hard:
            if hardType == "Increment" {
                lastExercise.currentReps += hardIncrement
            } else {
                lastExercise.currentReps *= (hardPercent/100 + 1)
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
    }

    func generateRandomExercise(exercises: [Exercise]) {
        let activeExercises = exercises.filter({ $0.isActive == true })
        let exercisesWithoutLast = activeExercises.filter({ $0.id != exercise?.id })
        if let randomElement = exercisesWithoutLast.randomElement() {
            print("Random exercise: \(randomElement)")
            randomExercise = randomElement.id.uuidString
            exercise = fetchExerciseById(id: (UUID(uuidString: randomElement.id.uuidString))!)

        } else {
            print("No random exercise found")
            if let randomElement = activeExercises.randomElement() {
                randomExercise = randomElement.id.uuidString
                exercise = fetchExerciseById(id: UUID(uuidString: randomElement.id.uuidString)!)
            }
        }
    }
    
    func fetchExerciseById(id: UUID) -> Exercise? {
        @Query var exercises: [Exercise]
        
        return exercises.first

        return nil
    }

    
    func finished(exercises: [Exercise]) {
        createLog(difficulty: difficulty, lastExercise: exercise!)
        WidgetCenter.shared.reloadAllTimelines()

        let exerciseType = HKWorkoutActivityType.functionalStrengthTraining
        let startDate = Date()
        let duration = TimeInterval(stopwatchViewModel.seconds) // 30 minutes
        let endDate = startDate.addingTimeInterval(duration)

        saveWorkout(exerciseType: exerciseType, startDate: startDate, endDate: endDate, duration: duration)
        generateRandomExercise(exercises: Array(exercises))
        stopwatchViewModel.reset()
    }
}
