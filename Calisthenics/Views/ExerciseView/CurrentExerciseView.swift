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
                            .onChange(of: finishedTapped) { newValue in
                                if newValue {
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
                                    exerciseViewModel.exercise = exerciseViewModel.fetchExerciseById(id: UUID(uuidString: randomExercise)!)
                                }
                            }
                        }
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
