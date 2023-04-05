//
//  StashedExerciseView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/27/23.
//

import SwiftUI
import WidgetKit
import HealthKit

struct StashedExerciseView: View {
    let moc = PersistenceController.shared.container.viewContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: []) var exercises: FetchedResults<StashExercise>
    @AppStorage("randomStashExercise") var randomStashExercise = ""
    @AppStorage("positiveLabel") var positiveLabel = "Finished"
    @AppStorage("negativeLabel") var negativeLabel = "Could Not Finish"
    @AppStorage("positiveRate") var positiveRate = 0.1
    @AppStorage("negativeRate") var negativeRate = -0.1
    @FocusState private var textFieldIsFocused: Bool
    @StateObject var viewModel = StopwatchViewModel()
    var numStashed: Int {
        exercises.count
    }
    var someExercise: StashExercise {
        exercises
            .filter { $0.goal != "Inactive" }
            .first(where: { $0.id?.uuidString == randomStashExercise }) ?? StashExercise()
    }
    
    var body: some View {
        if exercises.isEmpty {
            Text("No exercices")
                .onAppear {
                    dismiss()
                }
        }
        else if exercises.first(where: { $0.id?.uuidString == randomStashExercise }) == nil {
            Text("No exercices")
                .onAppear {
                    generateRandomExercise()
                }
        } else {
            VStack {
                List {
                    Section {
                        Text(someExercise.title ?? "didn't work")
                        if someExercise.units == "Reps" {
                            Text(String(Int(someExercise.currentReps)))
                        } else if someExercise.units == "Duration" {
                            Text(String(format: "%01d:%02d", Int(someExercise.currentReps) / 60, Int(someExercise.currentReps) % 60))
                        }
                        if (someExercise.notes!.count > 0) {
                            Text(someExercise.notes!)
                        }
                    }
                    Section {
                        Button(positiveLabel) {
                            finishedOrNot(finished: true)
                            removeStashedExercise()
                        }
                        .disabled(viewModel.seconds == 0)
                    }
                    Section {
                        Button(negativeLabel) {
                            finishedOrNot(finished: false)
                            removeStashedExercise()
                        }
                        .disabled(viewModel.seconds == 0)
                    }
                    Section {
                        Text("\(numStashed) stashed exercises")
                    }
                }
                StopwatchView(viewModel: viewModel)
                    .padding()

            }
            .navigationTitle("Stashed Exercises")
        }
    }
    
    func removeStashedExercise() {
        moc.delete(someExercise)
        try? moc.save()
    }
    
    func createLog(finished: Bool) {
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(exactly: viewModel.seconds)!
        newLog.exercise = someExercise.title
        newLog.reps = Int16(exactly: someExercise.currentReps.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = someExercise.units
        
        if finished {
            if (someExercise.goal == "Maintain") && (Int(someExercise.currentReps) != Int(someExercise.maintainReps)) {
                if someExercise.currentReps > someExercise.maintainReps {
                    someExercise.currentReps = someExercise.maintainReps
                } else {
                    someExercise.currentReps += positiveRate
                }
            } else {
                someExercise.currentReps += positiveRate
            }
        } else if !finished {
            if someExercise.goal == "Maintain" {
                if someExercise.currentReps > someExercise.maintainReps {
                    someExercise.currentReps = someExercise.maintainReps
                }
                someExercise.currentReps += negativeRate
            }
            // go back to the last completed amount
            someExercise.currentReps += negativeRate
        }
        try? moc.save()
    }
    
    func finishedOrNot(finished: Bool) {
        createLog(finished: finished)
        generateRandomExercise()
        textFieldIsFocused.toggle()
        WidgetCenter.shared.reloadAllTimelines()
        
        let exerciseType = HKWorkoutActivityType.functionalStrengthTraining
        let startDate = Date()
        let duration = TimeInterval(viewModel.seconds) // 30 minutes
        let endDate = startDate.addingTimeInterval(duration)
        
        saveWorkout(exerciseType: exerciseType, startDate: startDate, endDate: endDate, duration: duration)
        viewModel.reset()
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
    
    func generateRandomExercise() {
        print("Exercises count: \(exercises.count)")
        
        if let randomElement = exercises.randomElement() {
            print("Random exercise: \(randomElement)")
            
            if let uuidString = randomElement.id?.uuidString {
                print("UUID string: \(uuidString)")
                randomStashExercise = uuidString
            } else {
                print("UUID string is empty")
            }
        } else {
            print("No random exercise found")
        }
    }
}
