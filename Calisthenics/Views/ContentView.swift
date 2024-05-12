import SwiftData
import SwiftUI
import WidgetKit
import PopupView

struct ContentView: View {
    @ObservedObject private var defaultsManager = DefaultsManager()
    
    @Query var stashedExercises: [StashedExercise]
    @Query var allExercises: [Exercise]
    
    @State private var showInstructions: Bool = false

    @AppStorage("firstLaunch") var firstLaunch: Bool = true

    @AppStorage("randomExercise") var randomExercise: String = ""

    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate

    @AppStorage("easyType") var easyType = "Increment"
    @AppStorage("easyText") var easyText = "Didn't have to pause"
    @AppStorage("easyIncrement") var easyIncrement = 0.5
    @AppStorage("easyPercent") var easyPercent = 0.5
    
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

    
    @AppStorage("showAd") private var showAd = false
    @AppStorage("currentTab") var currentTab: Int = 0
    
    @StateObject private var adManager = AdManager()  // Assuming you have this from previous examples
    @StateObject var exerciseViewModel = ExerciseViewModel.shared

    
    var body: some View {
        TabView(selection: $currentTab) {
            CurrentExerciseView()
                .tabItem {
                    Label("Exercise", systemImage: "figure.core.training")
                }
                .tag(0)
                .onAppear {
                    defaultsManager.loadSettings()
                }
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
            defaultsManager.loadSettings()
            if let randomExerciseUUID = UUID(uuidString: randomExercise),
               let newExercise = fetchExerciseById(id: randomExerciseUUID, exercises: allExercises) {
                exerciseViewModel.exercise = newExercise
            }

        }
        .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)) { _ in
            defaultsManager.loadSettings()
        }
        .fullScreenCover(isPresented: $firstLaunch) {
            FirstLauchView()
        }
//        .sheet(isPresented: $showInstructions) {
//            TutorialView()
//        }

        
    }
    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        print("LOGG: \(id.description)")
        print("LOGG: \(exercises)")
        
        return exercises.first(where: { $0.id!.description == id.description })
    }
}

