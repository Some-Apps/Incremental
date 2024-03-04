//
//  AddExerciseView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var units = "Reps"
    @State private var startingReps = 30.0
    @State private var startingDuration = 30.0
    @State private var notes = ""
//    @State private var selectedMuscles = Set<String>()
    
    var body: some View {
        Form {
            Section {
                TextField("Exercise Title", text: $title)
                Picker("Units", selection: $units) {
                    ForEach(unitOptions, id: \.self) { unit in
                        Text(unit)
                    }
                }
//                NavigationLink {
//                    MuscleSelectorView(muscles: $selectedMuscles)
//                } label: {
//                    HStack {
//                        Text("Muscles")
//                        Spacer()
//                        let totalMuscles = selectedMuscles.count
//                        Text(totalMuscles == 1 ? "1 muscle" : "\(totalMuscles) muscles")
//                            .foregroundColor(.secondary)
//                    }
//                }

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
            Section("Notes") {
                TextEditor(text: $notes)
            }
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
        let newExercise = Exercise(context: modelContext)
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

//struct MultipleSelectionRow: View {
//    var title: String
//    var isSelected: Bool
//    var action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text(title)
//                    .foregroundColor(isSelected ? .accentColor : .primary)
//                if isSelected {
//                    Spacer()
//                    Image(systemName: "checkmark")
//                }
//            }
//        }
//    }
//}
//
//struct MuscleSelectorView: View {
//    @Binding var muscles: Set<String>
//    
//    var body: some View {
//        List {
//            ForEach(muscleOptions, id: \.self) { option in
//                muscleSelectionRow(title: option)
//            }
//        }
//    }
//    
//    private func muscleSelectionRow(title: String) -> some View {
//        MultipleSelectionRow(title: title, isSelected: muscles.contains(title)) {
//            if muscles.contains(title) {
//                muscles.remove(title)
//            } else {
//                muscles.insert(title)
//            }
//        }
//    }
//}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
