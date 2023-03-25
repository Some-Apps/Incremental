//
//  EditExerciseView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/25/23.
//

import SwiftUI

struct EditExerciseView: View {
    let moc = PersistenceController.shared.container.viewContext
    @Environment(\.dismiss) var dismiss
    @AppStorage("randomExercise") var randomExercise = ""
    let exercise: Exercise

    let goals = ["Improve", "Maintain"]
    let units = ["Reps", "Duration"]

    @State private var selectedTitle: String
    @State private var selectedGoal: String
    @State private var selectedUnits: String
    @State private var selectedNotes: String

    init(exercise: Exercise) {
        self.exercise = exercise

        self._selectedTitle = State(initialValue: exercise.title ?? "")
        self._selectedGoal = State(initialValue: exercise.goal ?? "")
        self._selectedUnits = State(initialValue: exercise.units ?? "")
        self._selectedNotes = State(initialValue: exercise.notes ?? "")
    }

    
    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    TextField("Squats", text: $selectedTitle)
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                    Picker("Units", selection: $selectedUnits) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                }
                Section("Notes") {
                    TextEditor(text: $selectedNotes)
                }
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                }
                Section {
                    Button("Delete") {
                        delete()
                    }
                }
            }
        }
    }
    
    func saveChanges() {
        exercise.title = selectedTitle
        exercise.goal = selectedGoal
        exercise.units = selectedUnits
        exercise.notes = selectedNotes
        try? moc.save()
        dismiss()
    }
    
    private func delete() {
        var exercisesToDelete: [Exercise] = []
        
        if exercise.id?.uuidString != randomExercise {
            exercisesToDelete.append(exercise)
            dismiss()
        } else {
            print("Nope")
        }
        
        exercisesToDelete.forEach(moc.delete)
        try? moc.save()
    }
}

//struct EditExerciseView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditExerciseView()
//    }
//}
