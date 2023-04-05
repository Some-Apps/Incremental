//
//  RepertoireView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct RepertoireView: View {
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

    var body: some View {
        NavigationStack {
            List {
                Section("Active") {
                    ForEach(activeExercises, id: \.self) { exercise in
                        NavigationLink(destination: EditExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unkown")
                                .bold(exercise.goal == "Maintain" ? true : false)
                        }
                        .disabled((exercise.id?.uuidString == randomExercise) || exercise.id?.uuidString == randomStashExercise)
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
