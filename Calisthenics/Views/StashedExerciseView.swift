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
    @FocusState private var textFieldIsFocused: Bool
    @StateObject var viewModel = StopwatchViewModel()
    var numStashed: Int {
        exercises.count
    }
    var exercise: StashExercise {
        exercises.first(where: { $0.id?.uuidString == randomStashExercise }) ?? StashExercise()
    }
    
    var body: some View {
        if exercises.isEmpty {
            Text("No exercices")
                .onAppear {
                    dismiss()
                }
        } else if randomStashExercise == "" {
            Text("No exercices")
                .onAppear {
                    generateRandomExercise()
                }
        } else {
            VStack {
                List {
                    Section {
                        Text(exercise.title!)
                        if exercise.units == "Reps" {
                            Text(String(Int(exercise.currentReps)))
                        } else if exercise.units == "Duration" {
                            Text(String(format: "%01d:%02d", Int(exercise.currentReps) / 60, Int(exercise.currentReps) % 60))
                        }
                        if (exercise.notes!.count > 0) {
                            Text(exercise.notes!)
                        }
                    }
                    Section {
                        Button("Finished") {
                            finishedOrNot(finished: true)
                            removeStashedExercise()
                        }
                        .disabled(viewModel.seconds == 0)
                    }
                    Section {
                        Button("Could Not Finish") {
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
        moc.delete(exercise)
        try? moc.save()
    }
    
    func createLog(finished: Bool) {
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(exactly: viewModel.seconds)!
        newLog.exercise = exercise.title
        newLog.reps = Int16(exactly: exercise.currentReps.rounded(.down))!
        newLog.timestamp = Date()
        
        if finished {
            if (exercise.goal == "Maintain") && (Int(exercise.currentReps) != Int(exercise.maintainReps)) {
                if exercise.currentReps > exercise.maintainReps {
                    exercise.currentReps = exercise.maintainReps
                } else {
                    exercise.currentReps += exercise.rate
                    exercise.rate *= 1.1
                }
            } else {
                exercise.currentReps += exercise.rate
                exercise.rate *= 1.1
            }
        } else if !finished {
            if exercise.goal == "Maintain" {
                if exercise.currentReps > exercise.maintainReps {
                    exercise.currentReps = exercise.maintainReps
                }
                exercise.currentReps -= exercise.rate
                exercise.rate = 0.25
            }
            // go back to the last completed amount
            exercise.currentReps -= exercise.rate
            // reset positiveRate
            exercise.rate = 0.25
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


//struct StashedExerciseView_Previews: PreviewProvider {
//    static var previews: some View {
//        StashedExerciseView()
//    }
//}
