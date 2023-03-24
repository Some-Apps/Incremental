//
//  AddExerciseView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) var dismiss
    let moc = PersistenceController.shared.container.viewContext
    
    let goals = ["Improve", "Maintain"]
    let units = ["Reps", "Duration"]
    
    @State private var selectedTitle = ""
    @State private var selectedGoal = "Improve"
    @State private var selectedUnits = "Reps"
    @State private var selectedCurrentReps = 0.0
    @State private var selectedCurrentDuration = 0.0
    
    var body: some View {
        VStack {
            List {
                Section {
                    TextField("Title", text: $selectedTitle)
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
                    if selectedUnits == "Reps" {
                        DoubleTextField("Reps", value: $selectedCurrentReps)
                    } else if selectedUnits == "Duration" {
                        DoubleTextField("Duration", value: $selectedCurrentDuration)
                    }
                }
                Section {
                    Button("Add Exercise") {
                        let newExercise = Exercise(context: moc)
                        newExercise.id = UUID()
                        newExercise.title = selectedTitle
                        newExercise.goal = selectedGoal
                        newExercise.units = selectedUnits
                        newExercise.currentReps = selectedCurrentReps
                        newExercise.currentDuration = selectedCurrentDuration
                        newExercise.positiveRate = 0.5
                        newExercise.negativeRate = 1
                        try? moc.save()
                        dismiss()
                    }
                    .disabled(selectedCurrentDuration == 0.0 && selectedCurrentReps == 0.0)
                }
            }
        }
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}

struct DoubleTextField: View {
    let label: String
    @Binding var value: Double
    private let formatter = NumberFormatter()

    init(_ label: String, value: Binding<Double>) {
        self.label = label
        self._value = value
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
    }

    var body: some View {
        TextField("Enter value", value: $value, formatter: formatter)
    }
}
