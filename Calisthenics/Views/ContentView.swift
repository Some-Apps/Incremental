import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @StateObject private var defaultsManager = DefaultsManager()
    
    @Query var stashedExercises: [StashedExercise]
    
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
    @AppStorage("holdDuration") var holdDuration: Double = 0

    
    @AppStorage("showAd") private var showAd = false
    @AppStorage("currentTab") var currentTab: Int = 0
    
    @StateObject private var adManager = AdManager()  // Assuming you have this from previous examples

    
    var body: some View {
        TabView(selection: $currentTab) {
            CurrentExerciseView()
                .tabItem {
                    Label("Exercise", systemImage: "figure.core.training")
                }
                .tag(0)
            StashedExereciseView()
                .tabItem {
                    Label("Stashed", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
                .badge(stashedExercises.count)
            RepertoireView()
                .tabItem {
                    Label("Repertoire", systemImage: "list.clipboard")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .fullScreenCover(isPresented: $showAd) {
                        AdView(adManager: adManager, showAd: $showAd)
                    }
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
            currentTab = 0
            self.easyType = defaultsManager.getDataFromiCloud(key: "easyType") as? String ?? "Increment"
            self.easyText = defaultsManager.getDataFromiCloud(key: "easyText") as? String ?? "Didn't have to pause"
            self.easyIncrement = defaultsManager.getDataFromiCloud(key: "easyIncrement") as? Double ?? 0.5
            self.easyPercent = defaultsManager.getDataFromiCloud(key: "easyPercent") as? Double ?? 1

            self.mediumType = defaultsManager.getDataFromiCloud(key: "mediumType") as? String ?? "Increment"
            self.mediumText = defaultsManager.getDataFromiCloud(key: "mediumText") as? String ?? "Had to pause but didn't have to take a break"
            self.mediumIncrement = defaultsManager.getDataFromiCloud(key: "mediumIncrement") as? Double ?? 0.1
            self.mediumPercent = defaultsManager.getDataFromiCloud(key: "mediumPercent") as? Double ?? 0.1

            self.hardType = defaultsManager.getDataFromiCloud(key: "hardType") as? String ?? "Increment"
            self.hardText = defaultsManager.getDataFromiCloud(key: "hardText") as? String ?? "Had to take a break or 3 pauses"
            self.hardIncrement = defaultsManager.getDataFromiCloud(key: "hardIncrement") as? Double ?? -2
            self.hardPercent = defaultsManager.getDataFromiCloud(key: "hardPercent") as? Double ?? -5
            
            self.maxStashed = defaultsManager.getDataFromiCloud(key: "maxStashed") as? Int ?? 10
            self.holdDuration = defaultsManager.getDataFromiCloud(key: "holdDuration") as? Double ?? 0
            self.holdDuration = defaultsManager.getDataFromiCloud(key: "lastHoldTime") as? Double ?? 0

        }
        .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)) { _ in
            self.easyType = defaultsManager.getDataFromiCloud(key: "easyType") as? String ?? "Increment"
            self.easyText = defaultsManager.getDataFromiCloud(key: "easyText") as? String ?? "Didn't have to pause"
            self.easyIncrement = defaultsManager.getDataFromiCloud(key: "easyIncrement") as? Double ?? 0.5
            self.easyPercent = defaultsManager.getDataFromiCloud(key: "easyPercent") as? Double ?? 1

            self.mediumType = defaultsManager.getDataFromiCloud(key: "mediumType") as? String ?? "Increment"
            self.mediumText = defaultsManager.getDataFromiCloud(key: "mediumText") as? String ?? "Had to pause but didn't have to take a break"
            self.mediumIncrement = defaultsManager.getDataFromiCloud(key: "mediumIncrement") as? Double ?? 0.1
            self.mediumPercent = defaultsManager.getDataFromiCloud(key: "mediumPercent") as? Double ?? 0.1

            self.hardType = defaultsManager.getDataFromiCloud(key: "hardType") as? String ?? "Increment"
            self.hardText = defaultsManager.getDataFromiCloud(key: "hardText") as? String ?? "Had to take a break or 3 pauses"
            self.hardIncrement = defaultsManager.getDataFromiCloud(key: "hardIncrement") as? Double ?? -2
            self.hardPercent = defaultsManager.getDataFromiCloud(key: "hardPercent") as? Double ?? -5
            
            self.maxStashed = defaultsManager.getDataFromiCloud(key: "maxStashed") as? Int ?? 10
            self.holdDuration = defaultsManager.getDataFromiCloud(key: "holdDuration") as? Double ?? 0
            self.holdDuration = defaultsManager.getDataFromiCloud(key: "lastHoldTime") as? Double ?? 0                    }
    }
}

