//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var defaultsManager = DefaultsManager()

    
    @AppStorage("easyType") var easyType = "Increment"
    @AppStorage("easyText") var easyText = "Didn't have to pause"
    @AppStorage("easyIncrement") var easyIncrement = 0.5
    @AppStorage("easyPercent") var easyPercent = 1.0
    
    @AppStorage("mediumType") var mediumType = "Increment"
    @AppStorage("mediumText") var mediumText = "Had to pause but didn't have to take a break"
    @AppStorage("mediumIncrement") var mediumIncrement =  0.1
    @AppStorage("mediumPercent") var mediumPercent = 0.1
    
    @AppStorage("hardType") var hardType = "Increment"
    @AppStorage("hardText") var hardText = "Had to take a break or 3 pauses"
    @AppStorage("hardIncrement") var hardIncrement = -2.0
    @AppStorage("hardPercent") var hardPercent = -5.0
    
    @AppStorage("maxStashed") var maxStashed = 10
    
    @State private var tempEasyType = "Increment"
    @State private var tempMediumType = "Increment"
    @State private var tempHardType = "Increment"
    @State private var tempEasyText = "Didn't have to pause"
    @State private var tempMediumText = "Didn't have to pause"
    @State private var tempHardText = "Didn't have to pause"
    @State private var tempEasyPercent = 1.0
    @State private var tempMediumPercent = 0.1
    @State private var tempHardPercent = -5.0
    @State private var tempEasyIncrement = 0.5
    @State private var tempMediumIncrement = 0.1
    @State private var tempHardIncrement = -2.0
    @State private var tempmMaxStashed: Int = 10

    
    @AppStorage("holdDuration") var holdDuration: Double = 0
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate
    
    @State private var confirmSaveSettings = false
    
    let typeOptions = ["Percent", "Increment"]

    
    var body: some View {
        NavigationStack {
            Form {
                Section("Easy") {
                    Picker("Type", selection: $tempEasyType) {
                        ForEach(typeOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    if tempEasyType == "Increment" {
                        Stepper("\(tempEasyIncrement, specifier: "%.2f")", value: $tempEasyIncrement, step: 0.05)
                    } else {
                        Stepper("\(tempEasyPercent, specifier: "%.2f")%", value: $tempEasyPercent, step: 0.05)
                    }
                    TextEditor(text: $tempEasyText)
                        .frame(minHeight:  75)
                }
                .disabled(!isEligibleForChange())

                Section("Medium") {
                    Picker("Type", selection: $tempMediumType) {
                        ForEach(typeOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    if tempMediumType == "Increment" {
                        Stepper("\(tempMediumIncrement, specifier: "%.2f")", value: $tempMediumIncrement, step: 0.05)
                    } else {
                        Stepper("\(tempMediumPercent, specifier: "%.2f")%", value: $tempMediumPercent, step: 0.05)
                    }
                    TextEditor(text: $tempMediumText)
                        .frame(minHeight:  75)

                }
                .disabled(!isEligibleForChange())

                Section("Hard") {
                    Picker("Type", selection: $tempHardType) {
                        ForEach(typeOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    if tempHardType == "Increment" {
                        Stepper("\(tempHardIncrement, specifier: "%.2f")", value: $tempHardIncrement, step: 0.05)
                    } else {
                        Stepper("\(tempHardPercent, specifier: "%.2f")%", value: $tempHardPercent, step: 0.05)
                    }
                    TextEditor(text: $tempHardText)
                        .frame(minHeight:  75)

                }
                .disabled(!isEligibleForChange())
                Section {
                    Stepper("Stash Limit: \(tempmMaxStashed)", value: $tempmMaxStashed, step: 1)
                }
                .disabled(!isEligibleForChange())
                Section {
                    if isEligibleForChange() {
                        Button("Save Changes") {
                            confirmSaveSettings.toggle()
                        }
                        .confirmationDialog("Confirm Settings", isPresented: $confirmSaveSettings) {
                            Button("Yes") {
                                easyType = tempEasyType
                                easyPercent = tempEasyPercent
                                easyIncrement = tempEasyIncrement
                                easyText = tempEasyText
                                mediumType = tempMediumType
                                mediumPercent = tempMediumPercent
                                mediumIncrement = tempMediumIncrement
                                mediumText = tempMediumText
                                hardType = tempHardType
                                hardPercent = tempHardPercent
                                hardIncrement = tempHardIncrement
                                hardText = tempHardText
                                maxStashed = tempmMaxStashed
                                holdDuration = 0
                                
                                defaultsManager.saveDataToiCloud(key: "easyType", value: easyType)
                                defaultsManager.saveDataToiCloud(key: "easyText", value: easyText)
                                defaultsManager.saveDataToiCloud(key: "easyPercent", value: easyPercent)
                                defaultsManager.saveDataToiCloud(key: "easyIncrement", value: easyIncrement)
                                
                                defaultsManager.saveDataToiCloud(key: "mediumType", value: mediumType)
                                defaultsManager.saveDataToiCloud(key: "mediumText", value: mediumText)
                                defaultsManager.saveDataToiCloud(key: "mediumPercent", value: mediumPercent)
                                defaultsManager.saveDataToiCloud(key: "mediumIncrement", value: mediumIncrement)
                                
                                defaultsManager.saveDataToiCloud(key: "hardType", value: hardType)
                                defaultsManager.saveDataToiCloud(key: "hardText", value: hardText)
                                defaultsManager.saveDataToiCloud(key: "hardPercent", value: hardPercent)
                                defaultsManager.saveDataToiCloud(key: "hardIncrement", value: hardIncrement)
                                
                                defaultsManager.saveDataToiCloud(key: "maxStashed", value: maxStashed)

                                defaultsManager.saveDataToiCloud(key: "holdDuration", value: holdDuration)


                            }
                            Button("Nevermind", role: .cancel) {
                                
                            }
                        } message: {
                            Text("Confirm this budget?")
                        }
                    } else {
                        NavigationLink("Enable Changes", destination: EnableChanges())
                    }
                }
            }
            .onAppear {
                cleanUpOldDurations()
                tempEasyType = easyType
                tempEasyPercent = easyPercent
                tempEasyIncrement = easyIncrement
                tempEasyText = easyText
                tempMediumType = mediumType
                tempMediumPercent = mediumPercent
                tempMediumIncrement = mediumIncrement
                tempMediumText = mediumText
                tempHardType = hardType
                tempHardPercent = hardPercent
                tempHardIncrement = hardIncrement
                tempHardText = hardText
                tempmMaxStashed = maxStashed
            }
        }
        
    }
    
    private func cleanUpOldDurations() {
        let now = Date()
        let lastHoldEndTime = Date(timeIntervalSinceReferenceDate: lastHoldTime)
        
        // Reset holdDuration if it's a new day
        if !Calendar.current.isDate(lastHoldEndTime, inSameDayAs: now) {
            holdDuration = 0
        }
    }
    
    private func isEligibleForChange() -> Bool {
        // Check if holdDuration meets the new requirement of 20 minutes within a single day
        let eligible = holdDuration >= 600 // 20 minutes expressed in seconds
        print("Is eligible for change: \(eligible)")
        return eligible
    }
}


