//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI
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
                        Text(randomExercise)
                        Text(exercise.title!)
                        Text(String(Int(exercise.currentReps)))
                    }
                    Section {
                        Button("Finished") {
                            createLog(finished: true)
                            generateRandomExercise()
                            viewModel.reset()
                            textFieldIsFocused.toggle()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        .disabled(viewModel.seconds == 0)
                    }
                    Section {
                        Button("Could Not Finish") {
                            createLog(finished: false)
                            generateRandomExercise()
                            viewModel.reset()
                            textFieldIsFocused.toggle()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        .disabled(viewModel.seconds == 0)
                    }
                }
                StopwatchView(viewModel: viewModel)
                .padding()
                
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
            exercise.currentReps += exercise.positiveRate
            exercise.positiveRate *= 1.1
            exercise.negativeRate /= 1.1
        } else {
            exercise.currentReps -= exercise.negativeRate
            exercise.positiveRate /= 1.1
            exercise.negativeRate *= 1.1
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
