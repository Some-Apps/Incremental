//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 4/5/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("positiveLabel") var positiveLabel = "Finished"
    @AppStorage("negativeLabel") var negativeLabel = "Could Not Finish"
    @AppStorage("positiveRate") var positiveRate = 0.1
    @AppStorage("negativeRate") var negativeRate = -0.1
    @AppStorage("secondsPerExercisePerDay") var secondsPerExercisePerDay = 30

    
    var body: some View {
        NavigationStack {
            Form {
                Section(positiveLabel) {
                    TextField("Label", text: $positiveLabel)
                    Stepper(value: $positiveRate, in: 0...1, step: 0.01) {
                        Text("Value: \(positiveRate, specifier: "%.2f")")
                    }
//                    TextEditor(text: $positiveNotes)
                }
                Section(negativeLabel) {
                    TextField("Label", text: $negativeLabel)
                    Stepper(value: $negativeRate, in: -1...(0), step: 0.01) {
                        Text("Value: \(negativeRate, specifier: "%.2f")")
                    }
//                    TextEditor(text: $negativeNotes)
                }
                Section {
                    Stepper(value: $secondsPerExercisePerDay, in: 30...240, step: 1) {
                        Text("Seconds/Exercise/Day: \(secondsPerExercisePerDay)")
                    }
                }
            }
        }
    }
}
