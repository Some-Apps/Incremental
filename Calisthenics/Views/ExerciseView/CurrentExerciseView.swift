//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import AlertToast
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData

struct CurrentExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var allExercises: [Exercise]


    @Query(filter: #Predicate<Exercise> { exercise in
        exercise.isActive == true
    }) var exercises: [Exercise]
    
    @Query var logs: [Log]
    
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

    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = ExerciseViewModel.shared
    
    @State private var difficulty: Difficulty = .medium
    @State private var lastExercise: Exercise? = nil
    @State private var finishedTapped = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if exerciseViewModel.exercise != nil && randomExercise != "" && exercises.count > 1 {
                    VStack {
                        Text(totalDurationToday())
                        ExerciseCardView(finishedTapped: $finishedTapped)
                            .onChange(of: finishedTapped) {
                                if finishedTapped {
                                    finished(exercises: Array(exercises))
                                }
                            }
                        Spacer()
                        StopwatchView(viewModel: stopwatchViewModel)
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        requestAuthorization()
                    }
                    .toast(isPresenting: $finishedTapped) {
                        AlertToast(displayMode: .hud, type: .complete(.green), title: "Exercise completed!")
                        
                    }
                } else {
                    Text("At least 2 exercises required")
                        .onAppear {
                            print(randomExercise)
                            if exercises.isEmpty {
                                print("No exercises available")
                            } else {
                                
                                print("LOG: random")
                                print("LOG: \(randomExercise)")
                                if randomExercise == "" {
                                    generateRandomExercise(exercises: Array(exercises))
                                } else {
                                    exerciseViewModel.exercise = fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: allExercises)
                                }
                            }
                        }
                }
            }
        }
    }
    
    func totalDurationToday() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let logs = try! logs.filter(#Predicate<Log> { item in
            item.timestamp! >= startOfDay
        })
        
        let totalDuration = logs.reduce(0) { $0 + TimeInterval($1.duration!) }
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
        print("LOG: creating log")
        let newLog = Log(backingData: Log.createBackingData())
        newLog.id = UUID()
        newLog.duration = Int16(exactly: stopwatchViewModel.seconds)!
        newLog.reps = Int16(exactly: lastExercise.currentReps!.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = lastExercise.units

        print("LOG: \(difficulty)")

        lastExercise.difficulty = difficulty.rawValue

        switch difficulty {
        case .easy:
            if easyType == "Increment" {
                lastExercise.currentReps! += easyIncrement
            } else {
                lastExercise.currentReps! *= (easyPercent/100 + 1)
            }
        case .medium:
            if mediumType == "Increment" {
                lastExercise.currentReps! += mediumIncrement
            } else {
                lastExercise.currentReps! *= (mediumPercent/100 + 1)
            }
        case .hard:
            if hardType == "Increment" {
                lastExercise.currentReps! += hardIncrement
            } else {
                lastExercise.currentReps! *= (hardPercent/100 + 1)
            }
        }
        modelContext.insert(newLog)
        try? modelContext.save()

    }

    func generateRandomExercise(exercises: [Exercise]) {
        let activeExercises = exercises.filter({ $0.isActive == true })
        let exercisesWithoutLast = activeExercises.filter({ $0.id != exerciseViewModel.exercise?.id })
        if let randomElement = exercisesWithoutLast.randomElement() {
            print("Random exercise: \(randomElement)")
            randomExercise = randomElement.id!.uuidString
            exerciseViewModel.exercise = fetchExerciseById(id: (UUID(uuidString: randomElement.id!.uuidString))!, exercises: exercises)

        } else {
            print("No random exercise found")
            if let randomElement = activeExercises.randomElement() {
                randomExercise = randomElement.id!.uuidString
                exerciseViewModel.exercise = fetchExerciseById(id: UUID(uuidString: randomElement.id!.uuidString)!, exercises: exercises)
            }
        }
    }
    
    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        print("LOGG: \(id.description)")
        print("LOGG: \(exercises)")
        
        return exercises.first(where: { $0.id!.description == id.description })
    }

    
    func finished(exercises: [Exercise]) {
        createLog(difficulty: difficulty, lastExercise: exerciseViewModel.exercise!)
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
