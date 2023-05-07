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
    @AppStorage("positiveNotes") var positiveNotes = "I was able to complete the exercise in one set"
    @AppStorage("negativeNotes") var negativeNotes = "I had to take a break to complete the exercise"
    
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
            }
        }
    }
}
