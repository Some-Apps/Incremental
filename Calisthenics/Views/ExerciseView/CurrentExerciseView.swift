//
//  ExercisesView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import AlertToast
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData

struct CurrentExerciseView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Exercise> { exercise in
        exercise.isActive == true
    }) var exercises: [Exercise]
    
    @Query var logs: [Log]
    
    @AppStorage("randomExercise") var randomExercise: String = ""

    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = ExerciseViewModel.shared
    
    @State private var difficulty: Difficulty = .medium
    @State private var lastExercise: Exercise? = nil
    @State private var finishedTapped = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if exerciseViewModel.exercise != nil && randomExercise != "" && exercises.count > 1 {
                    VStack {
                        Text(totalDurationToday())
                        ExerciseCardView(finishedTapped: $finishedTapped)
                            .onChange(of: finishedTapped) {
                                if finishedTapped {
                                    exerciseViewModel.finished(exercises: Array(exercises))
                                }
                            }
                        Spacer()
                        StopwatchView(viewModel: stopwatchViewModel)
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        exerciseViewModel.requestAuthorization()
                    }
                    .toast(isPresenting: $finishedTapped) {
                        AlertToast(displayMode: .hud, type: .complete(.green), title: "Exercise completed!")
                        
                    }
                } else {
                    Text("At least 2 exercises required")
                        .onAppear {
                            print(randomExercise)
                            if exercises.isEmpty {
                                print("No exercises available")
                            } else {
                                
                                print("LOG: random")
                                print("LOG: \(randomExercise)")
                                if randomExercise == "" {
                                    exerciseViewModel.generateRandomExercise(exercises: Array(exercises))
                                } else {
                                    exerciseViewModel.exercise = exerciseViewModel.fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: exercises)
                                }
                            }
                        }
                }
            }
        }
    }
    
    func totalDurationToday() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let logs = try! logs.filter(#Predicate<Log> { item in
            item.timestamp! >= startOfDay
        })
        
        let totalDuration = logs.reduce(0) { $0 + TimeInterval($1.duration!) }
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
