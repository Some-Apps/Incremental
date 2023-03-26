//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI
import HealthKit
import WidgetKit

struct CurrentExerciseView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: []) var exercises: FetchedResults<Exercise>
    @AppStorage("randomExercise") var randomExercise = ""
    @FocusState private var textFieldIsFocused: Bool
    @StateObject var viewModel = StopwatchViewModel()

    var exercise: Exercise {
        exercises.first(where: { $0.id?.uuidString == randomExercise }) ?? Exercise()
    }
    
    var body: some View {
        if randomExercise == "" {
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
                            createLog(finished: true)
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
                        .disabled(viewModel.seconds == 0)
                    }
                    Section {
                        Button("Could Not Finish") {
                            createLog(finished: false)
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
                        .disabled(viewModel.seconds == 0)
                    }
                }
                StopwatchView(viewModel: viewModel)
                .padding()
                
            }
            .onAppear {
                requestAuthorization()
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


    
    func createLog(finished: Bool) {
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(exactly: viewModel.seconds)!
        newLog.exercise = exercise.title
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
    
    func generateRandomExercise() {
        print("Exercises count: \(exercises.count)")
        
        if let randomElement = exercises.randomElement() {
            print("Random exercise: \(randomElement)")
            
            if let uuidString = randomElement.id?.uuidString {
                print("UUID string: \(uuidString)")
                randomExercise = uuidString
            } else {
                print("UUID string is empty")
            }
        } else {
            print("No random exercise found")
        }
    }

}

//struct ExercisesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentExerciseView()
//    }
//}
