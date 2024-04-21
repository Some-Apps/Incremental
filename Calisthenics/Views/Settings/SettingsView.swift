//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("easyType") var easyType = "Increment"
    @AppStorage("easyIncrement") var easyIncrement = 0.5
    @AppStorage("easyPercent") var easyPercent = 1.0
    @AppStorage("mediumType") var mediumType = "Increment"
    @AppStorage("mediumIncrement") var mediumIncrement =  0.1
    @AppStorage("mediumPercent") var mediumPercent = 0.1
    @AppStorage("hardType") var hardType = "Increment"
    @AppStorage("hardIncrement") var hardIncrement = -2.0
    @AppStorage("hardPercent") var hardPercent = -5.0
    
    let typeOptions = ["Percent", "Increment"]

    
    var body: some View {
        Form {
            Section("Easy") {
                Picker("Type", selection: $easyType) {
                    ForEach(typeOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                if easyType == "Increment" {
                    Stepper("\(easyIncrement, specifier: "%.2f")", value: $easyIncrement, step: 0.05)
                } else {
                    Stepper("\(easyPercent, specifier: "%.2f")%", value: $easyPercent, step: 0.05)
                }
            }
            Section("Medium") {
                Picker("Type", selection: $mediumType) {
                    ForEach(typeOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                if mediumType == "Increment" {
                    Stepper("\(mediumIncrement, specifier: "%.2f")", value: $mediumIncrement, step: 0.05)
                } else {
                    Stepper("\(mediumPercent, specifier: "%.2f")%", value: $mediumPercent, step: 0.05)
                }
            }
            Section("Hard") {
                Picker("Type", selection: $hardType) {
                    ForEach(typeOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                if hardType == "Increment" {
                    Stepper("\(hardIncrement, specifier: "%.2f")", value: $hardIncrement, step: 0.05)
                } else {
                    Stepper("\(hardPercent, specifier: "%.2f")%", value: $hardPercent, step: 0.05)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
