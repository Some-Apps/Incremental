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
    
    @State private var duration = ""
    
    var exercise: Exercise {
        exercises.first(where: { $0.id?.uuidString == randomExercise }) ?? Exercise()
    }
    
    var body: some View {
        if randomExercise == "" {
            Text("No exercices")
                .onTapGesture {
                    generateRandomExercise()
                }
        } else {
            VStack {
                List {
                    Section {
                        Text(exercise.title!)
                        Text("\(exercise.currentReps!)")
                        TextField("Duration", text: $duration)
                    }
                    Section {
                        Button("Finished") {
                            generateRandomExercise()
                            createLog()
                            duration = ""
                        }
                        .disabled(duration == "" || Int(duration) == nil)
                    }
                }
            }
        }
    }
    
    func createLog() {
        let newLog = Log(context: moc)
        newLog.id = UUID()
        newLog.duration = Int16(duration)!
        newLog.exercise = exercise.title
        newLog.timestamp = Date()
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
