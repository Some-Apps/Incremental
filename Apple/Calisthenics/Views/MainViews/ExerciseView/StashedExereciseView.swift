import AlertToast
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData

struct StashedExereciseView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var exercises: [StashedExercise]
    @Query var originalExercises: [Exercise]
    @Query var logs: [Log]

    @AppStorage("healthActivityCategory") var healthActivityCategory: String = "Functional Strength Training"
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = StashedExerciseViewModel.shared
    
    @State private var difficulty: Difficulty = .easy
    @State private var lastExercise: Exercise? = nil
    @State private var finishedTapped = false
    @State private var stashedExercise = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let currentExercise = exerciseViewModel.exercise, exercises.count > 0 {
                    VStack {
                        Text(totalDurationToday())
                        StashedExerciseCardView(finishedTapped: $finishedTapped, stashedExercise: $stashedExercise, tempDifficulty: $difficulty)
                            .onChange(of: finishedTapped) {
                                if finishedTapped {
                                    finished(exercises: Array(exercises))
                                }
                            }
                            .onAppear {
                                exerciseViewModel.exercise = exercises.first
                                for exercise in exercises {
                                    if (fetchExerciseById(id: exercise.id!, exercises: originalExercises) == nil) {
                                        modelContext.delete(exercise)
                                        try? modelContext.save()
                                    }
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
                    Text("No stashed exercises")
                        .onAppear {
                            exerciseViewModel.exercise = exercises.first
                            for exercise in exercises {
                                if (fetchExerciseById(id: exercise.id!, exercises: originalExercises) == nil) {
                                    modelContext.delete(exercise)
                                    try? modelContext.save()
                                }
                            }
                        }
                }
            }
        }
    }
    
    func totalDurationToday() -> String {
        let newLogs = logs.filter( { Calendar.autoupdatingCurrent.isDateInToday($0.timestamp!) } )
        
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

    
    func createLog(difficulty: Difficulty, lastExercise: StashedExercise) {
        print("LOG: creating log")
        let exercise = fetchExerciseById(id: lastExercise.id!, exercises: originalExercises)
        let newLog = Log(backingData: Log.createBackingData())
        newLog.id = UUID()
        newLog.duration = Int16(exactly: stopwatchViewModel.seconds)!
        newLog.reps = Int16(exactly: lastExercise.currentReps!.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = lastExercise.units
        newLog.exercises = fetchExerciseById(id: lastExercise.id!, exercises: originalExercises)

        print("LOG: \(difficulty)")

        lastExercise.difficulty = difficulty.rawValue

        // Fetch the last 10 logs for this exercise
        let lastLogs = logs.filter { $0.exercises?.id == lastExercise.id }
            .sorted(by: { $0.timestamp! > $1.timestamp! })
            .prefix(10)

        // Count how many of the last 10 logs have an "easy" difficulty
        let hardCount = lastLogs.filter { $0.exercises?.difficulty == Difficulty.hard.rawValue }.count

        // Adjust incrementIncrement based on the count
        let maxIncrement = lastExercise.currentReps! * 0.05
        if let currentIncrementIncrement = lastExercise.incrementIncrement {
            var newIncrementIncrement = currentIncrementIncrement
            if hardCount >= 2 {
                newIncrementIncrement -= 0.03
            } else {
                newIncrementIncrement += 0.01
            }
            // Ensure incrementIncrement does not affect increment beyond 5% of currentReps
            if abs((lastExercise.increment ?? 0) + newIncrementIncrement) <= maxIncrement {
                lastExercise.incrementIncrement = newIncrementIncrement
            } else {
                lastExercise.incrementIncrement = 0 // stop incrementIncrement when increment is at 5%
                lastExercise.increment = maxIncrement // set increment to exactly 5% of currentReps
            }
        } else {
            lastExercise.incrementIncrement = hardCount >= 2 ? -0.03 : 0.01
        }

        // Update the current reps
        lastExercise.currentReps! += lastExercise.increment ?? 0

        // Increment
        switch difficulty {
        case .easy:
            if let currentIncrement = lastExercise.increment, let incrementIncrement = lastExercise.incrementIncrement {
                let newIncrement = currentIncrement + incrementIncrement
                // Ensure increment does not exceed 5% of currentReps
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
                }
            } else {
                lastExercise.increment = -0.03
            }
        }

        // Check for duplicate logs
        if logs.contains(where: { log in
            log.timestamp == newLog.timestamp && log.exercises?.id == newLog.exercises?.id
        }) {
            return
        }

        modelContext.insert(newLog)
        try? modelContext.save()
    }

    
    func finished(exercises: [StashedExercise]) {
        guard let currentExercise = exerciseViewModel.exercise else { return }

        // Log and workout saving functions.
        createLog(difficulty: difficulty, lastExercise: currentExercise)
        let exerciseType = HKWorkoutActivityType.coreTraining
        let startDate = Date()
        let duration = TimeInterval(stopwatchViewModel.seconds)
        let endDate = startDate.addingTimeInterval(duration)

        saveWorkout(startDate: startDate, endDate: endDate, duration: duration)

        // Remove the exercise from the context and save the changes.
        modelContext.delete(currentExercise)
        try? modelContext.save()

        // Update the exerciseViewModel with the next available exercise.
        exerciseViewModel.exercise = fetchNextAvailableExercise()

        // Reset the stopwatch after handling the exercise.
        stopwatchViewModel.reset()

        // Notify system to update widgets.
        WidgetCenter.shared.reloadAllTimelines()
    }

    func fetchNextAvailableExercise() -> StashedExercise? {
        // Assuming you reload or refetch the exercises from the modelContext here.
        let updatedExercises = exercises
        return updatedExercises.first
    }




    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        return originalExercises.first(where: { $0.id!.description == id.description })
    }
}
