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
    @State private var selectedNotes = ""
    @State private var selectedMaintainReps = ""
    
    
    var customBinding: Binding<String> {
        Binding<String>(
            get: {
                var formattedString = ""
                let inputNumbers = Array(selectedCurrentReps).compactMap { Int(String($0)) }
                
                guard inputNumbers.count >= 2 else {
                    return selectedCurrentReps
                }
                
                for i in 0..<(inputNumbers.count - 1) {
                    formattedString += String(format: "%02d", inputNumbers[i]) + ":"
                }
                
                formattedString += String(format: "%02d", inputNumbers.last!)
                return formattedString
            },
            set: { newValue in
                if let lastChar = newValue.last,
                   let lastNumber = Int(String(lastChar)),
                   lastNumber >= 0, lastNumber <= 9 {
                    selectedCurrentReps.append(lastChar)
                }
            }
        )
    }


    
    var body: some View {
        VStack {
            List {
                Section("General") {
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
                    
                }
                Section(selectedGoal == "Improve" ? "Starting" : "Maintain") {
                    TextField("Reps", text: selectedGoal == "Improve" ? $selectedCurrentReps : $selectedMaintainReps)
                        .keyboardType(.numberPad)
                }
                Section("Notes") {
                    TextEditor(text: $selectedNotes)
                }
                Section {
                    Button("Add Exercise") {
                        addExercise()
                        dismiss()
                    }
                }
            }
        }
    }
    
    func addExercise() {
        let newExercise = Exercise(context: moc)
        newExercise.id = UUID()
        newExercise.title = selectedTitle
        newExercise.goal = selectedGoal
        newExercise.units = selectedUnits
        newExercise.currentReps = Double(selectedCurrentReps) ?? 0.0
        newExercise.rate = 0.25
        newExercise.notes = selectedNotes
        newExercise.maintainReps = Double(selectedMaintainReps) ?? 0.0
        try? moc.save()
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
