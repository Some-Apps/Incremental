import SwiftUI
import SwiftData
import TipKit

struct RepertoireView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

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

    let addExerciseTip = AddExerciseTip()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(activeExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            Text(exercise.title ?? "Unknown")
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSetToDelete = indexSet
                        confirmDelete = true
                    })
                } header: {
                    Text("Active")
                        .foregroundStyle(colorScheme.current.secondaryText)
                }
                .listRowBackground(colorScheme.current.secondaryBackground)

                Section {
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
                } header: {
                    Text("Inactive")
                        .foregroundStyle(colorScheme.current.secondaryText)

                }
                .listRowBackground(colorScheme.current.secondaryBackground)

            }
            .listStyle(.automatic)
            .scrollContentBackground(.hidden)
            .background(colorScheme.current.primaryBackground)
            .foregroundStyle(colorScheme.current.primaryText, colorScheme.current.secondaryText)
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
                            .foregroundStyle(colorScheme.current.accentText)
                    }
                    .popoverTip(addExerciseTip)
                    .onTapGesture {
                        addExerciseTip.invalidate(reason: .actionPerformed)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundStyle(colorScheme.current.accentText)
                }
            }
        }
        .background(colorScheme.current.primaryBackground)
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
