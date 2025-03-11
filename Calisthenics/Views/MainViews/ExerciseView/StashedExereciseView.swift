import AlertToast
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData

struct StashedExereciseView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

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
                if (exerciseViewModel.exercise != nil), exercises.count > 0 {
                    VStack {
                        Text(totalDurationToday())
                            .foregroundStyle(colorScheme.current.primaryText)
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
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
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
                                .foregroundStyle(colorScheme.current.primaryText)
                            Spacer()
                        }
                        Spacer()
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
        newLog.title = lastExercise.title ?? "Unknown"
        newLog.id = UUID()
        newLog.duration = Int16(exactly: stopwatchViewModel.seconds)!
        newLog.reps = lastExercise.currentReps
        newLog.timestamp = Date()
        newLog.units = lastExercise.units
        newLog.exercise = fetchExerciseById(id: lastExercise.id!, exercises: originalExercises)

        print("LOG: \(difficulty)")

        lastExercise.difficulty = difficulty.rawValue

        // Update the current reps
        lastExercise.currentReps! += (difficulty == .easy ? lastExercise.increment : 0) ?? 0
        lastExercise.difficulty = difficulty.rawValue


        // Check for duplicate logs
        if logs.contains(where: { log in
            log.timestamp == newLog.timestamp && log.exercise?.id == newLog.exercise?.id
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
