import AlertToast
import SwiftUI
import HealthKit
import WidgetKit
import StoreKit
import SwiftData
import TipKit

struct CurrentExerciseView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) var requestReview
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false

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
                    .onChange(of: logs) {
                        print("[LOG] LOGS: \(logs.count)")
                        if isSubscribed && logs.count % 500 == 0 {
                            requestReview()
                        }
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
            .background(colorScheme.current.primaryBackground)
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
        newLog.reps = lastExercise.currentReps
        newLog.timestamp = Date()
        newLog.units = lastExercise.units
        newLog.difficulty = difficulty.rawValue
        newLog.side = lastExercise.leftRight ?? false ? lastExercise.leftSide ?? true ? "left" : "right" : ""
        newLog.exercise = lastExercise

        print("[LOG] \(lastExercise.title ?? "Unknown")")
        
        // Fetch the last 10 logs for this exercise
        var lastLogs = logs.filter { $0.exercise?.id == lastExercise.id }
            .sorted(by: { $0.timestamp! > $1.timestamp! })
            .prefix(99)
        lastLogs.insert(newLog, at: 0)
        
        let lastEasyLog = lastLogs.first { $0.difficulty == Difficulty.easy.rawValue }

        print("[LOG] # of logs: \(lastLogs.count)")

        let effectiveLogCount = min(lastLogs.count, 100)
        
        print("[LOG] effective log count: \(effectiveLogCount)")
        
        let totalWeight = lastLogs.enumerated().reduce(0.0) { (result, element) in
            let (index, log) = element
            let weight = 1.0 - (Double(index) / Double(effectiveLogCount))
            return result + (log.difficulty == Difficulty.hard.rawValue ? weight : 0.0)
        }

        print("[LOG] total weight: \(totalWeight)")

        // Calculate the maximum increment
        let maxIncrement = lastExercise.currentReps! * 0.03
        print("[LOG] max increment: \(maxIncrement)")
        
        if let currentIncrementIncrement = lastExercise.incrementIncrement {
            var newIncrementIncrement = currentIncrementIncrement
            
            if totalWeight <= 0.5 {
                newIncrementIncrement += 0.015
            } else if totalWeight <= 1 {
                newIncrementIncrement += 0.01
            } else if totalWeight <= 1.5 {
                newIncrementIncrement -= 0.01
            } else if totalWeight <= 2 {
                newIncrementIncrement -= 0.02
            } else if totalWeight <= 2.5 {
                newIncrementIncrement -= 0.05
            } else if totalWeight <= 3 {
                newIncrementIncrement -= 0.1
            } else {
                newIncrementIncrement -= 0.2
            }
            
            print("[LOG] new increment based on weight: \(newIncrementIncrement)")
            
            // Calculate the potential new increment
            let potentialNewIncrement = (lastExercise.increment ?? 0) + newIncrementIncrement
            
            // Check if the potential increment is within bounds
            if potentialNewIncrement >= -maxIncrement && potentialNewIncrement <= maxIncrement {
                lastExercise.incrementIncrement = newIncrementIncrement
            } else {
                lastExercise.incrementIncrement = 0
                lastExercise.increment = 0
            }
            
        } else {
            lastExercise.incrementIncrement = 0
        }
        print("[LOG] this should match the line above unless reaching the max increment: \(lastExercise.incrementIncrement ?? 0)")

        // Increment
        switch difficulty {
        case .easy:
            if let currentIncrement = lastExercise.increment, let incrementIncrement = lastExercise.incrementIncrement {
                let newIncrement = currentIncrement + incrementIncrement
                lastExercise.increment = newIncrement
            } else {
                lastExercise.increment = 0
            }
        case .hard:
            print("[LOG] hard")
            if let currentIncrement = lastExercise.increment, let incrementIncrement = lastExercise.incrementIncrement {
                print("[LOG] successfully unwrapped")

                if currentIncrement > 0 {
                    print("[LOG] greater than 0")
                    if let lastEasyLog = lastEasyLog {
                        print("[LOG] went to easy log")
                        if let currentReps = lastExercise.currentReps {
                            let lastEasyReps = Double(lastEasyLog.reps ?? Double(lastExercise.currentReps!.rounded(.down)))
                            lastExercise.increment = lastEasyReps - currentReps
                            lastExercise.incrementIncrement = 0
                        }
                    } else {
                        lastExercise.increment = 0
                        lastExercise.incrementIncrement = 0
                    }
                } else {
                    print("[LOG] less than 0")
                    let newIncrement = currentIncrement + incrementIncrement
                    lastExercise.increment = newIncrement
                }
            } else {
                print("[LOG] failed to unwrap")
                lastExercise.increment = 0
            }
        }
        // Update the current reps
        lastExercise.currentReps! += lastExercise.increment ?? 0
        lastExercise.difficulty = difficulty.rawValue
        
        print("[LOG] increment: \(lastExercise.increment ?? 100)")

        // Check for duplicate logs
        if logs.contains(where: { log in
            log.timestamp == newLog.timestamp && log.exercise?.id == newLog.exercise?.id
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

