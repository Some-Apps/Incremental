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
    @FetchRequest(sortDescriptors: []) var stashedExercises: FetchedResults<StashExercise>
    @AppStorage("randomExercise") var randomExercise = ""
    @AppStorage("positiveLabel") var positiveLabel = "Finished"
    @AppStorage("negativeLabel") var negativeLabel = "Could Not Finish"
    @AppStorage("positiveRate") var positiveRate = 0.1
    @AppStorage("negativeRate") var negativeRate = -0.1
    @FocusState private var textFieldIsFocused: Bool
    @StateObject var viewModel = StopwatchViewModel()
    var numStashed: Int {
        stashedExercises.count
    }
    var exercise: Exercise? {
        let filteredExercises = exercises.filter { $0.goal != "Inactive" }
        if let matchedExercise = filteredExercises.first(where: { $0.id?.uuidString == randomExercise }) {
            return matchedExercise
        } else {
            generateRandomExercise()
            return filteredExercises.first(where: { $0.id?.uuidString == randomExercise }) ?? nil
        }
    }


    
    var body: some View {
        NavigationStack {
            if (exercise != nil) {
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
                            Button(positiveLabel) {
                                finishedOrNot(finished: true)
                            }
                            .disabled(viewModel.seconds == 0)
                        }
                        Section {
                            Button(negativeLabel) {
                                finishedOrNot(finished: false)
                            }
                            .disabled(viewModel.seconds == 0)
                        }
                        Section {
                            Button("Stash Exercise") {
                                stashExercise()
                                generateRandomExercise()
                            }
                            Text("\(numStashed) stashed exercises")
                            NavigationLink("Complete Stashed Exercises", destination: StashedExerciseView())
                        }
                    }
                    StopwatchView(viewModel: viewModel)
                        .padding()
                    
                }
                .onAppear {
                    requestAuthorization()
                }
            } else {
                Text("No exercices")
                    .onAppear {
                        generateRandomExercise()
                    }
            }
        }
    }
        
    
    func stashExercise() {
        let newStashedExercise = StashExercise(context: moc)
        newStashedExercise.currentReps = exercise!.currentReps
        newStashedExercise.units = exercise!.units
        newStashedExercise.maintainReps = exercise!.maintainReps
        newStashedExercise.notes = exercise!.notes
        newStashedExercise.title = exercise!.title
        newStashedExercise.goal = exercise!.goal
        newStashedExercise.id = exercise!.id
        try? moc.save()
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
        newLog.exercise = exercise!.title
        newLog.reps = Int16(exactly: exercise!.currentReps.rounded(.down))!
        newLog.timestamp = Date()
        newLog.units = exercise!.units
        
        if finished {
            if (exercise!.goal == "Maintain") && (Int(exercise!.currentReps) != Int(exercise!.maintainReps)) {
                if exercise!.currentReps > exercise!.maintainReps {
                    exercise!.currentReps = exercise!.maintainReps
                } else {
                    exercise!.currentReps += positiveRate
                }
            } else {
                exercise!.currentReps += positiveRate
            }
        } else if !finished {
            if exercise!.goal == "Maintain" {
                if exercise!.currentReps > exercise!.maintainReps {
                    exercise!.currentReps = exercise!.maintainReps
                }
                exercise!.currentReps += negativeRate
            }
            // go back to the last completed amount
            exercise!.currentReps += negativeRate
        }
        try? moc.save()
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
