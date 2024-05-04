//
//  RepertoireView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI
import SwiftData

struct RepertoireView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var defaultsManager = DefaultsManager()

    @Query(filter: #Predicate<Exercise> {item in
        item.isActive ?? true
    }, sort: \.title) var activeExercises: [Exercise]

    @Query(filter: #Predicate<Exercise> { item in
        item.isActive != true ?? false
    }, sort: \.title) var inactiveExercises: [Exercise]

    @Environment(\.editMode) private var editMode
    @State private var confirmDelete = false
    @State private var indexSetToDelete: IndexSet?
    @AppStorage("randomExercise") var randomExercise: String = ""


    var body: some View {
        NavigationStack {
            List {
                Section("Active") {
                    ForEach(activeExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unknown")
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSetToDelete = indexSet
                        confirmDelete = true
                    })
                }
                Section("Inactive") {
                    ForEach(inactiveExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unknown")
                        }
                    }
                    // Assuming you want the same delete behavior for inactive exercises
                    .onDelete(perform: { indexSet in
                        indexSetToDelete = indexSet
                        confirmDelete = true
                    })
                }
            }
            .confirmationDialog("Are you sure you want to delete this exercise?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let indexSet = indexSetToDelete {
                        deleteExercise(at: indexSet)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        AddExerciseView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        
    }

    private func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            let exercise = activeExercises[index]
            if exercise.id?.uuidString == randomExercise {
                randomExercise = ""
                defaultsManager.saveDataToiCloud(key: "randomExercise", value: randomExercise)
            }
            modelContext.delete(exercise)
        }
        
        do {
            try modelContext.save()
            indexSetToDelete = nil
        } catch {
            print("Failed to save context after deleting exercise: \(error)")
        }
    }
}
