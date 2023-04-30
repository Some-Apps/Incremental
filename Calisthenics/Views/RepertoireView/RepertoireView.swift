//
//  RepertoireView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct RepertoireView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var logs: FetchedResults<Log>
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)],
        predicate: NSPredicate(format: "goal != %@", "Inactive")
    ) var activeExercises: FetchedResults<Exercise>

    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)],
        predicate: NSPredicate(format: "goal == %@", "Inactive")
    ) var inactiveExercises: FetchedResults<Exercise>
    @Environment(\.editMode) private var editMode
    @AppStorage("randomExercise") var randomExercise = ""
    @AppStorage("randomStashExercise") var randomStashExercise = ""
    @State private var showSettings = false
    @State private var showAdd = false
    
    var activeExerciseLimit: Int {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let recentLogs = logs.filter { $0.timestamp! >= thirtyDaysAgo }
        let logsByDay = Dictionary(grouping: recentLogs, by: { Calendar.current.startOfDay(for: $0.timestamp!) })
        let totalSeconds = logsByDay.values.reduce(0) { (result, dailyLogs) -> Int in
            result + dailyLogs.map { Int($0.duration) }.reduce(0, +)
        }
        let totalMinutes = totalSeconds / 60
        let averageMinutes = totalMinutes / 30
        let unroundedLimit = Double(averageMinutes) / 1.1
        return Int(unroundedLimit)
    }
    
    var activeExercisesCount: Int {
        return activeExercises.count
    }

    var body: some View {
        NavigationStack {
            Text("\(activeExercisesCount)/\(activeExerciseLimit) Exercises")
            List {
                Section("Active") {
                    ForEach(activeExercises, id: \.self) { exercise in
                        NavigationLink(destination: EditExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unkown")
                        }
                    }
                }
                Section("Inactive") {
                    ForEach(inactiveExercises, id: \.self) { exercise in
                        NavigationLink(destination: EditExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unknown")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdd.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(activeExercisesCount >= activeExerciseLimit && activeExercisesCount != 0)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAdd) {
            AddExerciseView()
        }
    }
}
