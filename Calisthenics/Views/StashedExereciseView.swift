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
    
    @AppStorage("easyType") var easyType = "Increment"
    @AppStorage("easyIncrement") var easyIncrement = 0.5
    @AppStorage("easyPercent") var easyPercent = 0.5
    @AppStorage("mediumType") var mediumType = "Increment"
    @AppStorage("mediumIncrement") var mediumIncrement =  0.1
    @AppStorage("mediumPercent") var mediumPercent = 0.1
    @AppStorage("hardType") var hardType = "Increment"
    @AppStorage("hardIncrement") var hardIncrement = -2.0
    @AppStorage("hardPercent") var hardPercent = -5.0

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
    
    func saveWorkout(exerciseType: HKWorkoutActivityType, startDate: Date, endDate: Date, duration: TimeInterval) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let healthStore = HKHealthStore()
        
        // Specify the types of data this workout will include; adjust these as needed for your app.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set<HKObjectType> = []
        
        // Request authorization for the types of data your app needs.
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
                    
                    // End the workout collection at the specified end date
                    builder.endCollection(withEnd: endDate) { (success, error) in
                        guard success else {
                            if let error = error {
                                print("Error ending collection: \(error.localizedDescription)")
                            }
                            return
                        }
                        
                        // Finish building the workout
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
        

        switch difficulty {
        case .easy:
            if easyType == "Increment" {
                exercise?.currentReps = lastExercise.currentReps! + easyIncrement
            } else {
                exercise?.currentReps! = lastExercise.currentReps! * (easyPercent/100 + 1)
            }
        case .hard:
            if hardType == "Increment" {
                exercise!.currentReps = lastExercise.currentReps! + hardIncrement
            } else {
                exercise!.currentReps = lastExercise.currentReps! * (hardPercent/100 + 1)
            }
        }
        modelContext.insert(newLog)
        modelContext.delete(lastExercise)
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

        saveWorkout(exerciseType: exerciseType, startDate: startDate, endDate: endDate, duration: duration)

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
