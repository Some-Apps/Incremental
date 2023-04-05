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

    let goals = ["Improve", "Maintain", "Inactive"]
    let units = ["Reps", "Duration"]

    @State private var selectedTitle: String
    @State private var selectedGoal: String
    @State private var selectedUnits: String
    @State private var selectedMaintainReps: String
    @State private var selectedNotes: String

    init(exercise: Exercise) {
        self.exercise = exercise

        self._selectedTitle = State(initialValue: exercise.title ?? "")
        self._selectedGoal = State(initialValue: exercise.goal ?? "")
        self._selectedUnits = State(initialValue: exercise.units ?? "")
        self._selectedMaintainReps = State(initialValue: String(Int(exercise.currentReps)))
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
                if selectedGoal == "Maintain" {
                    Section("Maintain Reps") {
                        TextField("Reps", text: $selectedMaintainReps)
                            .keyboardType(.numberPad)
                    }
                }
                Section("Notes") {
                    TextEditor(text: $selectedNotes)
                }
                Section("View Only") {
                    Text("Current Reps: \(String(format: "%.1f", exercise.currentReps))")
                }
                .foregroundColor(.secondary)
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                }
                Section {
                    Button("Delete", role: .destructive) {
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
        exercise.maintainReps = Double(selectedMaintainReps) ?? 0.0
        try? moc.save()
        dismiss()
    }
    
    private func delete() {
        var exercisesToDelete: [Exercise] = []
        exercisesToDelete.append(exercise)
        dismiss()
        print("Nope")
        exercisesToDelete.forEach(moc.delete)
        try? moc.save()
    }
}

//struct EditExerciseView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditExerciseView()
//    }
//}
