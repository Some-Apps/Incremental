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
    @State private var selectedCurrentReps = ""
    @State private var selectedCurrentDuration = ""
    
    var body: some View {
        VStack {
            Form {
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
                        TextField("Reps", text: $selectedCurrentReps)
                    } else if selectedUnits == "Duration" {
                        TextField("Seconds", text: $selectedCurrentDuration)
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
                        try? moc.save()
                        dismiss()
                    }
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
