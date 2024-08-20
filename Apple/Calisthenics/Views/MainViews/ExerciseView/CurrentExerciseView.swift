import AlertToast
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData
import TipKit

struct CurrentExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var defaultsManager = DefaultsManager()

    @Query var allExercises: [Exercise]

    @Query(filter: #Predicate<Exercise> { exercise in
        exercise.isActive == true
    }) var exercises: [Exercise]

    @Query var logs: [Log]

    @AppStorage("randomExercise") var randomExercise: String = ""
    @AppStorage("healthActivityCategory") var healthActivityCategory: String = "Functional Strength Training"
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = ExerciseViewModel.shared

    @State private var difficulty: Difficulty = .easy
    @State private var lastExercise: Exercise? = nil
    @State private var finishedTapped = false
    @State private var stashedExercise = false
    
    let goToRepertoireTip = GoToRepertoireTip()

    var body: some View {
        NavigationStack {
            VStack {
                if exerciseViewModel.exercise != nil && randomExercise != "" && exercises.count > 1 {
                    VStack {
                        Text(totalDurationToday())
                        ExerciseCardView(finishedTapped: $finishedTapped, stashedExercise: $stashedExercise, tempDifficulty: $difficulty)
                            .onChange(of: finishedTapped) {
                                if finishedTapped {
                                    finished(exercises: Array(exercises))
                                }
                            }
                            .onChange(of: stashedExercise) {
                                if stashedExercise {
                                    generateRandomExercise(exercises: Array(exercises))
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
                    .toast(isPresenting: $stashedExercise) {
                        AlertToast(displayMode: .hud, type: .complete(.orange), title: "Exercise stashed!")
                    }
                } else {
                    Text("At least 2 exercises required")
                        .onAppear {
                            if exercises.isEmpty {
                                print("No exercises available")
                            } else {
                                if randomExercise == "" {
                                    generateRandomExercise(exercises: Array(exercises))
                                } else {
                                    if let randomExerciseUUID = UUID(uuidString: randomExercise),
                                       let newExercise = fetchExerciseById(id: randomExerciseUUID, exercises: allExercises) {
                                        exerciseViewModel.exercise = newExercise
                                    } else {
                                        generateRandomExercise(exercises: Array(exercises))
                                    }
                                }
                            }
                        }
                        .popoverTip(goToRepertoireTip)
                }

            }
        }
    }

    func totalDurationToday() -> String {
        let newLogs = logs.filter { Calendar.autoupdatingCurrent.isDateInToday($0.timestamp!) }
        let totalDuration = newLogs.reduce(0) { $0 + TimeInterval($1.duration!) }
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

    func saveWorkout(startDate: Date, endDate: Date, duration: TimeInterval) {
        
        var exerciseType: HKWorkoutActivityType
        
        switch healthActivityCategory {
        case "Core Training":
            exerciseType = HKWorkoutActivityType.coreTraining
        case "Functional Strength Training":
            exerciseType = HKWorkoutActivityType.functionalStrengthTraining
        case "High-Intensity Interval Training":
            exerciseType = HKWorkoutActivityType.highIntensityIntervalTraining
        case "Mixed Cardio":
            exerciseType = HKWorkoutActivityType.mixedCardio
        case "Other":
            exerciseType = HKWorkoutActivityType.other
        case "Traditional Strength Training":
            exerciseType = HKWorkoutActivityType.traditionalStrengthTraining
        default:
            exerciseType = HKWorkoutActivityType.functionalStrengthTraining
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let healthStore = HKHealthStore()
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set<HKObjectType> = []

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                return
            }

            if success {
                let configuration = HKWorkoutConfiguration()
                configuration.activityType = exerciseType
                configuration.locationType = .unknown // Adjust this as necessary

                let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())

                builder.beginCollection(withStart: startDate) { (success, error) in
                    guard success else {
                        if let error = error {
                            print("Error beginning collection: \(error.localizedDescription)")
                        }
                        return
                    }

                    builder.endCollection(withEnd: endDate) { (success, error) in
                        guard success else {
                            if let error = error {
                                print("Error ending collection: \(error.localizedDescription)")
                            }
                            return
                        }

                        builder.finishWorkout { (workout, error) in
                            if let error = error {
                                print("Error finishing workout: \(error.localizedDescription)")
                            } else {
                                print("Successfully saved workout: \(String(describing: workout))")
                            }
                        }
                    }
                }

            } else {
                print("Authorization was not successful")
            }
        }
    }

    func createLog(difficulty: Difficulty, lastExercise: Exercise) {
        let newLog = Log(backingData: Log.createBackingData())
        newLog.id = UUID()
        newLog.duration = Int16(exactly: stopwatchViewModel.seconds)!
        newLog.reps = Int16(exactly: lastExercise.currentReps!.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = lastExercise.units
        newLog.exercises = lastExercise

        lastExercise.difficulty = difficulty.rawValue

        // Fetch the last 10 logs for this exercise
        let lastLogs = logs.filter { $0.exercises?.id == lastExercise.id }
            .sorted(by: { $0.timestamp! > $1.timestamp! })
            .prefix(100)

        // Count how many of the last 100 logs have a "hard" difficulty
//        let hardCount = lastLogs.filter { $0.exercises?.difficulty == Difficulty.hard.rawValue }.count
        
        let effectiveLogCount = min(lastLogs.count, 100)
        let totalWeight = lastLogs.enumerated().reduce(0.0) { (result, element) in
            let (index, log) = element
            let weight = 1.0 - (Double(index) / Double(effectiveLogCount))
            return result + (log.exercises?.difficulty == Difficulty.hard.rawValue ? weight : 0.0)
        }

        // Adjust incrementIncrement based on the count
        let maxIncrement = lastExercise.currentReps! * 0.03
        if let currentIncrementIncrement = lastExercise.incrementIncrement {
            var newIncrementIncrement = currentIncrementIncrement

            
            if totalWeight <= 1.0 {
                newIncrementIncrement += 0.015
            } else if totalWeight <= 2.0 {
                newIncrementIncrement += 0.01
            } else if totalWeight <= 3.0 {
                newIncrementIncrement += 0.005
            } else if totalWeight <= 5.0 {
                newIncrementIncrement -= 0.01
            } else if totalWeight <= 7.0 {
                newIncrementIncrement -= 0.05
            } else if totalWeight <= 15.0 {
                newIncrementIncrement -= 0.1
            } else {
                newIncrementIncrement -= 0.2
            }

            
            
            // Ensure incrementIncrement does not affect increment beyond 5% of currentReps
            if abs((lastExercise.increment ?? 0) + newIncrementIncrement) <= maxIncrement {
                lastExercise.incrementIncrement = newIncrementIncrement
            } else {
                lastExercise.incrementIncrement = 0 // stop incrementIncrement when increment is at 5%
                lastExercise.increment = maxIncrement // set increment to exactly 5% of currentReps
            }
        } else {
            lastExercise.incrementIncrement = 0.01
        }


        // Increment
        switch difficulty {
        case .easy:
            if let currentIncrement = lastExercise.increment, let incrementIncrement = lastExercise.incrementIncrement {
                let newIncrement = currentIncrement + incrementIncrement
                // Ensure increment does not exceed 3% of currentReps
                if abs(newIncrement) <= maxIncrement {
                    lastExercise.increment = newIncrement
                } else {
                    lastExercise.increment = maxIncrement
                }
            } else {
                lastExercise.increment = 0.01
            }
        case .hard:
            if let currentIncrement = lastExercise.increment {
                if currentIncrement > 0 {
                    lastExercise.increment = 0
                    lastExercise.currentReps = max(1, lastExercise.currentReps! - 1)
                }
            } else {
                lastExercise.increment = 0
            }
        }
        
        // Update the current reps
        lastExercise.currentReps! += lastExercise.increment ?? 0


        // Check for duplicate logs
        if logs.contains(where: { log in
            log.timestamp == newLog.timestamp && log.exercises?.id == newLog.exercises?.id
        }) {
            return
        }

        modelContext.insert(newLog)
        try? modelContext.save()
    }



    func generateRandomExercise(exercises: [Exercise]) {
        let activeExercises = exercises.filter { $0.isActive == true }
        let exercisesWithoutLast = activeExercises.filter { $0.id != exerciseViewModel.exercise?.id }
        if let randomElement = exercisesWithoutLast.randomElement() {
            randomExercise = randomElement.id!.uuidString
            randomElement.leftSide?.toggle()
            try? randomElement.modelContext?.save()
            defaultsManager.saveDataToiCloud(key: "randomExercise", value: randomExercise)
            exerciseViewModel.exercise = randomElement
        } else {
            if let randomElement = activeExercises.randomElement() {
                randomExercise = randomElement.id!.uuidString
                randomElement.leftSide?.toggle()
                try? randomElement.modelContext?.save()
                exerciseViewModel.exercise = randomElement
            }
        }
    }

    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        return exercises.first(where: { $0.id == id })
    }

    func finished(exercises: [Exercise]) {
        createLog(difficulty: difficulty, lastExercise: exerciseViewModel.exercise!)
        WidgetCenter.shared.reloadAllTimelines()

//        let exerciseType = HKWorkoutActivityType.coreTraining
        let startDate = Date()
        let duration = TimeInterval(stopwatchViewModel.seconds)
        let endDate = startDate.addingTimeInterval(duration)

        saveWorkout(startDate: startDate, endDate: endDate, duration: duration)
        generateRandomExercise(exercises: Array(exercises))
        stopwatchViewModel.reset()
    }
}
