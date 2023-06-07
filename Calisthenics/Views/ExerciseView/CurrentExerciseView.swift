//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import AlertToast
import CoreData
import SwiftUI
import HealthKit
import WidgetKit

struct CurrentExerciseView: View {
    let moc = PersistenceController.shared.container.viewContext

        @FetchRequest(
            entity: Exercise.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "isActive == %@", NSNumber(value: true))
        ) var exercises: FetchedResults<Exercise>

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

    @StateObject var stopwatchViewModel = StopwatchViewModel()
    @StateObject var exerciseViewModel = ExerciseViewModel()
    
    @State private var difficulty: Difficulty = .medium
    @State private var lastExercise: Exercise? = nil
    
    @State private var finishedTapped = false

    var exercise: Exercise? {
        guard !randomExercise.isEmpty else { return nil }
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", randomExercise)
        do {
            let result = try moc.fetch(request)
            if let fetchedExercise = result.first {
                DispatchQueue.main.async {
                    print(fetchedExercise.difficulty)
                    difficulty = Difficulty(rawValue: fetchedExercise.difficulty!) ?? .medium
                }
                return fetchedExercise
            } else {
                // Exercise with the provided UUID not found.
                // Generate a new random exercise.
                generateRandomExercise()
                return nil
            }
        } catch {
            print("Failed to fetch exercise: \(error)")
            return nil
        }
    }



    var body: some View {
        NavigationStack {
            if (exercise != nil && randomExercise != "" && exercises.count > 1) {
                VStack {
                    Text(totalDurationToday())
                    ExerciseCardView(exercise: exercise!, seconds: stopwatchViewModel.seconds, difficulty: $difficulty, finishedTapped: $finishedTapped, isRunning: $stopwatchViewModel.isRunning)
                        .onChange(of: finishedTapped) {
                            if finishedTapped {
                                finished(difficulty: exerciseViewModel.difficulty)
                            } else {
                                exerciseViewModel.fetchExercise()

                            }
                        }
                    //                    Button("Finished") {
//                        finished(difficulty: difficulty)
//                    }
//                    .disabled(stopwatchViewModel.seconds < 5)
//                    .buttonStyle(.bordered)
//                    .tint(.green)
//                    .font(.title)
                    StopwatchView(viewModel: stopwatchViewModel)
                        .padding()

                }
                .onAppear {
                    requestAuthorization()
                    exerciseViewModel.fetchExercise()
                }
                .toast(isPresenting: $finishedTapped) {
                    AlertToast(displayMode: .hud, type: .complete(.green), title: "Exercise completed!")
                        
                }
            } else {
                Text("At least 2 exercises required")
                    .onAppear {
                        if exercises.isEmpty {
                            print("No exercises available")
                        } else {
                            exerciseViewModel.generateRandomExercise()
                        }
                    }
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

    func finished(difficulty: Difficulty) {
        createLog(difficulty: difficulty)
        generateRandomExercise()
        WidgetCenter.shared.reloadAllTimelines()

        let exerciseType = HKWorkoutActivityType.functionalStrengthTraining
        let startDate = Date()
        let duration = TimeInterval(stopwatchViewModel.seconds) // 30 minutes
        let endDate = startDate.addingTimeInterval(duration)

        saveWorkout(exerciseType: exerciseType, startDate: startDate, endDate: endDate, duration: duration)
        stopwatchViewModel.reset()
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

    func createLog(difficulty: Difficulty) {
        lastExercise = exercise
        
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(exactly: stopwatchViewModel.seconds)!
        newLog.reps = Int16(exactly: lastExercise!.currentReps.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = lastExercise!.units

        // why isn't this actually saving the difficulty?
        lastExercise?.difficulty = difficulty.rawValue
        print(lastExercise?.difficulty)
        lastExercise?.addToLogs(newLog)

        switch difficulty {
        case .easy:
            if easyType == "Increment" {
                lastExercise?.currentReps += easyIncrement
            } else {
                lastExercise?.currentReps *= (easyPercent/100 + 1)
            }
        case .medium:
            if mediumType == "Increment" {
                lastExercise?.currentReps += mediumIncrement
            } else {
                lastExercise?.currentReps *= (mediumPercent/100 + 1)
            }
        case .hard:
            if hardType == "Increment" {
                lastExercise?.currentReps += hardIncrement
            } else {
                lastExercise?.currentReps *= (hardPercent/100 + 1)
            }
        }

        do {
            try moc.save()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
    }

    func generateRandomExercise() {
        let activeExercises = exercises.filter({ $0.isActive == true })
        let exercisesWithoutLast = activeExercises.filter({ $0.id != lastExercise?.id })
        if let randomElement = exercisesWithoutLast.randomElement() {
            print("Random exercise: \(randomElement)")
            if let uuidString = randomElement.id?.uuidString {
                randomExercise = uuidString
                print("UUID string: \(uuidString)")
            } else {
                print("UUID string is empty")
            }
        } else {
            print("No random exercise found")
            if let randomElement = activeExercises.randomElement() {
                if let uuidString = randomElement.id?.uuidString {
                    randomExercise = uuidString
                }
            }
        }
    }


    func totalDurationToday() -> String {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = NSPredicate(format: "(timestamp >= %@)", startOfDay as NSDate)
        fetchRequest.predicate = predicate
        
        do {
            let logs = try moc.fetch(fetchRequest)
            let totalDuration = logs.reduce(0) { $0 + TimeInterval($1.duration) }
            let minutes = Int(totalDuration) / 60
            let seconds = Int(totalDuration) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } catch {
            print("Failed to fetch Logs: \(error)")
            return "00:00"
        }
    }
}
