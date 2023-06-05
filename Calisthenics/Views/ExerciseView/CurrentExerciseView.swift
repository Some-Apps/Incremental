//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import CoreData
import SwiftUI
import HealthKit
import WidgetKit

struct CurrentExerciseView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: []) var exercises: FetchedResults<Exercise>

    @AppStorage("randomExercise") var randomExercise: String = ""
    @AppStorage("easyPercent") var easyPercent = 110
    @AppStorage("mediumPercent") var mediumPercent = 105
    @AppStorage("hardPercent") var hardPercent = 95

    @StateObject var viewModel = StopwatchViewModel()

    @State private var difficulty: Difficulty = .medium

    var exercise: Exercise? {
        guard !randomExercise.isEmpty else { return nil }
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", randomExercise)
        do {
            let result = try moc.fetch(request)
            return result.first
        } catch {
            print("Failed to fetch exercise: \(error)")
            return nil
        }
    }



    var body: some View {
        NavigationStack {
            if (exercise != nil && randomExercise != "") {
                VStack {
                    List {
                        Section {
                            Text(exercise!.title!)
                                .bold()
                            if exercise!.units == "Reps" {
                                Text(String(Int(exercise!.currentReps)))
                            } else if exercise!.units == "Duration" {
                                Text(String(format: "%01d:%02d", Int(exercise!.currentReps) / 60, Int(exercise!.currentReps) % 60))
                            }
                            if (exercise!.notes!.count > 0) {
                                Text(exercise!.notes!)
                                    .italic()
                            }
                        }
                        Section {
                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(Difficulty.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        Section {
                            Button("Finished") {
                                finished(difficulty: difficulty)
                            }
                        }
                    }
                    StopwatchView(viewModel: viewModel)
                        .padding()

                }
                .onAppear {
                    requestAuthorization()
                }
            } else {
                Text("No exercises")
                    .onAppear {
                        if exercises.isEmpty {
                            print("No exercises available")
                        } else {
                            generateRandomExercise()
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
        let duration = TimeInterval(viewModel.seconds) // 30 minutes
        let endDate = startDate.addingTimeInterval(duration)

        saveWorkout(exerciseType: exerciseType, startDate: startDate, endDate: endDate, duration: duration)
        viewModel.reset()
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
        let oldExercise = exercise
        
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(exactly: viewModel.seconds)!
        newLog.reps = Int16(exactly: oldExercise!.currentReps.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = oldExercise!.units

        oldExercise?.addToLogs(newLog)

        switch difficulty {
        case .easy:
            oldExercise?.currentReps *= Double(easyPercent)/100
        case .medium:
            oldExercise?.currentReps *= Double(mediumPercent)/100
        case .hard:
            oldExercise?.currentReps *= Double(hardPercent)/100
        }

        do {
            try moc.save()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
    }

    func generateRandomExercise() {
        if let randomElement = exercises.randomElement() {
            print("Random exercise: \(randomElement)")
            if let uuidString = randomElement.id?.uuidString {
                randomExercise = uuidString
                print("UUID string: \(uuidString)")
            } else {
                print("UUID string is empty")
            }
        } else {
            print("No random exercise found")
        }
    }

}
