//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct ExercisesView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: []) var exercises: FetchedResults<Exercise>
    @AppStorage("randomExercise") var randomExercise = ""
    @FocusState private var textFieldIsFocused: Bool
    @State private var duration = ""
    @StateObject private var stopwatch = Stopwatch()
    
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
                        Text(String(Int(exercise.currentReps)))
                        TextField("Duration", text: $duration)
                            .keyboardType(.numberPad)
                            .focused($textFieldIsFocused)
                    }
                    Section {
                        Button("Finished") {
                            createLog(finished: true)
                            generateRandomExercise()
                            duration = ""
                            textFieldIsFocused.toggle()
                        }
                        .disabled(duration == "" || Int(duration) == nil)
                    }
                    Section {
                        Button("Could Not Finish") {
                            createLog(finished: false)
                            generateRandomExercise()
                            duration = ""
                            textFieldIsFocused.toggle()
                        }
                        .disabled(duration == "" || Int(duration) == nil)
                    }
                }
                VStack {
                    Text(stopwatch.displayTime)
                        .font(.system(size: 48, design: .monospaced))
                    
                    HStack {
                        Button(action: {
                            stopwatch.toggle()
                        }) {
                            Text(stopwatch.isRunning ? "Stop" : "Start")
                                .frame(minWidth: 80, minHeight: 40)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            stopwatch.reset()
                        }) {
                            Text("Reset")
                                .frame(minWidth: 80, minHeight: 40)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
            }
        }
    }
    
    func createLog(finished: Bool) {
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(duration)!
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

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}
