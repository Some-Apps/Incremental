//
//  RepertoireView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI
import SwiftData

struct RepertoireView: View {
//    let moc = PersistenceController.shared.container.viewContext
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate<Exercise> {item in
        item.isActive ?? true
    }, sort: \.title) var activeExercises: [Exercise]

    @Query(filter: #Predicate<Exercise> { item in
        item.isActive != true ?? false
    }, sort: \.title) var inactiveExercises: [Exercise]
    
    @Environment(\.editMode) private var editMode

    var body: some View {
        NavigationStack {
            List {
                Section("Active") {
                    ForEach(activeExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unknown")
                        }
                    }
                    .onDelete(perform: deleteExercise)
                }
                Section("Inactive") {
                    ForEach(inactiveExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            Text(exercise.title!)
                        }
                    }
                    .onDelete(perform: deleteExercise)
                }
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
            modelContext.delete(exercise)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after deleting exercise: \(error)")
        }
    }
}

