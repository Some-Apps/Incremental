//
//  DefaultsManager.swift
//  Calisthenics
//
//  Created by Jared Jones on 5/4/24.
//

import Foundation
import SwiftUI

class DefaultsManager: ObservableObject {
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate

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
    @AppStorage("holdDuration") var holdDuration: Double = 0.0
    
    func saveDataToiCloud(key: String, value: Any) {
        let store = NSUbiquitousKeyValueStore.default
        store.set(value, forKey: key)
        store.synchronize()  // Ensuring data is synced, though this is typically unnecessary as sync happens automatically
    }
    func getDataFromiCloud(key: String) -> Any? {
        let store = NSUbiquitousKeyValueStore.default
        return store.object(forKey: key)
    }
    func loadSettings() {
        self.easyType = getDataFromiCloud(key: "easyType") as? String ?? "Increment"
        self.easyText = getDataFromiCloud(key: "easyText") as? String ?? "Didn't have to pause"
        self.easyIncrement = getDataFromiCloud(key: "easyIncrement") as? Double ?? 0.5
        self.easyPercent = getDataFromiCloud(key: "easyPercent") as? Double ?? 1

        self.mediumType = getDataFromiCloud(key: "mediumType") as? String ?? "Increment"
        self.mediumText = getDataFromiCloud(key: "mediumText") as? String ?? "Had to pause but didn't have to take a break"
        self.mediumIncrement = getDataFromiCloud(key: "mediumIncrement") as? Double ?? 0.1
        self.mediumPercent = getDataFromiCloud(key: "mediumPercent") as? Double ?? 0.1

        self.hardType = getDataFromiCloud(key: "hardType") as? String ?? "Increment"
        self.hardText = getDataFromiCloud(key: "hardText") as? String ?? "Had to take a break or 3 pauses"
        self.hardIncrement = getDataFromiCloud(key: "hardIncrement") as? Double ?? -2
        self.hardPercent = getDataFromiCloud(key: "hardPercent") as? Double ?? -5
        
        self.maxStashed = getDataFromiCloud(key: "maxStashed") as? Int ?? 10
        self.holdDuration = getDataFromiCloud(key: "holdDuration") as? Double ?? 0.0
        self.lastHoldTime = getDataFromiCloud(key: "lastHoldTime") as? Double ?? Date.timeIntervalSinceReferenceDate
    }

}
