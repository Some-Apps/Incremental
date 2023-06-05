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
        
    @State private var title = ""
    @State private var units = "Reps"
    @State private var startingReps = 30.0
    @State private var startingDuration = 30.0
    @State private var notes = ""
    @State private var mainMuscles = Set<String>()
    @State private var accessoryMuscles = Set<String>()
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: $title)
                Picker("Units", selection: $units) {
                    ForEach(unitOptions, id: \.self) { unit in
                        Text(unit)
                    }
                }
                NavigationLink {
                    MuscleSelectorView(muscles: $mainMuscles, muscleType: "main")
                } label: {
                    HStack {
                        Text("Main Muscles")
                        Spacer()
                        Text(mainMuscles.count == 1 ? "1 muscle" : "\(mainMuscles.count) muscles")
                            .foregroundColor(.secondary)
                    }
                }
                NavigationLink {
                    MuscleSelectorView(muscles: $accessoryMuscles, muscleType: "accessory")
                } label: {
                    HStack {
                        Text("Accessory Muscles")
                        Spacer()
                        Text(accessoryMuscles.count == 1 ? "1 muscle" : "\(accessoryMuscles.count) muscles")
                            .foregroundColor(.secondary)
                    }
                }
            }
            if units == "Reps" {
                Section("Starting Reps") {
                    Stepper("\(Int(startingReps))", value: $startingReps)
                }
            } else if units == "Duration" {
                Section("Starting Duration") {
                    Stepper("\(timeFormatter())", value: $startingDuration)
                }
            }
//            Section("Notes") {
//                TextEditor(text: $notes)
//            }
        }
        .toolbar {
            ToolbarItem {
                Button("Save") {
                    addExercise()
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines) == "")
            }
        }
    }
    
    func timeFormatter() -> String {
        let minutes = Int(startingDuration / 60)
        let remainingSeconds = Int(startingDuration.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func addExercise() {
        let newExercise = Exercise(context: moc)
        newExercise.id = UUID()
        newExercise.isActive = true
        newExercise.title = title
        newExercise.units = units
        newExercise.currentReps = units == "Reps" ? Double(startingReps) : Double(startingDuration)
        newExercise.notes = notes
        newExercise.difficulty = "medium"
        try? moc.save()
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct MuscleSelectorView: View {
    @Binding var muscles: Set<String>
    let muscleType: String
    
    var body: some View {
        List(muscleType == "main" ? mainMuscleOptions : accessoryMuscleOptions, id: \.self) { option in
            MultipleSelectionRow(title: option, isSelected: muscles.contains(option)) {
                if muscles.contains(option) {
                    muscles.remove(option)
                } else {
                    muscles.insert(option)
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
