import SwiftData
import SwiftUI
import WidgetKit
import TipKit

struct ContentView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState
    
    @ObservedObject private var defaultsManager = DefaultsManager()
    @Environment(\.modelContext) var modelContext
    @Query var stashedExercises: [StashedExercise]
    @Query var allExercises: [Exercise]
    
    @State private var showInstructions: Bool = false
    @AppStorage("SelectedColorScheme") var selectedColorScheme = ""
    @AppStorage("showTips") var showTips: Bool = true
    @AppStorage("randomExercise") var randomExercise: String = ""
    
    @AppStorage("currentTab") var currentTab: Int = 0
    
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
            if stashedExercises.count > 0 {
                StashedExereciseView()
                    .tabItem {
                        Label("Stashed", systemImage: "clock.arrow.circlepath")
                    }
                    .badge("\(stashedExercises.count)/10")
                    .tag(1)
            } else {
                StashedExereciseView()
                    .tabItem {
                        Label("Stashed", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(1)
            }
            
            
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
        
        .onAppear {
            //            generateDummyData(modelContext: modelContext)
            WidgetCenter.shared.reloadAllTimelines()
            currentTab = 0
            
            defaultsManager.loadSettings()
            
            
            if let randomExerciseUUID = UUID(uuidString: defaultsManager.getDataFromiCloud(key: "randomExercise") as? String ?? ""),
               let newExercise = fetchExerciseById(id: randomExerciseUUID, exercises: allExercises) {
                exerciseViewModel.exercise = newExercise
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)) { _ in
            defaultsManager.loadSettings()
        }
    }
    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        return exercises.first(where: { $0.id!.description == id.description })
    }
    
    //
    //    func generateDummyData(modelContext: ModelContext) {
    //        // Check if dummy data already exists to avoid duplication
    //        let existingExercises = try? modelContext.fetch(FetchDescriptor<Exercise>())
    //        if existingExercises?.count ?? 0 > 0 {
    //            print("Dummy data already exists, skipping creation.")
    //            return
    //        }
    //
    //        let exerciseNames = [
    //            "Archer Pushups", "Bicycle Crunches", "Calf Raises", "Cherry Pickers", "Diamond Pushups",
    //            "Frog Stand", "Full Swipers", "Glute Bridges", "Hand Release Strict Pushups", "Hand Release Wide Pushups",
    //            "Hollow Body Crunches", "Leg Raises", "Lunges", "Neck Ups", "One Hand Knee Pushups",
    //            "Pike Pushups", "Plank", "Side Lying Hip Raises", "Side Plank", "Single Leg Calf Raises",
    //            "Single Leg Glute Bridge", "Squats", "Strict Pushups", "Supermen With Scaption", "Swipers",
    //            "Tuck Planche", "Wall Sit", "Wide Pushups"
    //        ]
    //
    //        // Generate exercises based on the provided names
    //        var exercises: [Exercise] = []
    //        for name in exerciseNames {
    //            let exercise = Exercise(
    //                currentReps: 37,
    //                difficulty: ["easy", "hard"].randomElement()!,
    //                id: UUID(),
    //                isActive: true,
    //                notes: "",
    //                title: name,
    //                units: "Reps",
    //                increment: Double.random(in: 1...2),
    //                incrementIncrement: Double.random(in: 0.1...0.5),
    //                leftRight: false,
    //                leftSide: Bool.random(),
    //                logs: []
    //            )
    //            exercises.append(exercise)
    //            modelContext.insert(exercise)
    //        }
    //
    //        // Generate 500 dummy logs
    //        for _ in 1...500 {
    //            let randomExercise = exercises.randomElement()!
    //            let log = Log(
    //                duration: Int16.random(in: 1...60),
    //                id: UUID(),
    //                reps: Double.random(in: 5...20),
    //                timestamp: Date().addingTimeInterval(-Double.random(in: 0...1000000)),
    //                units: randomExercise.units!,
    //                difficulty: randomExercise.difficulty!,
    //                side: randomExercise.leftRight! ? (Bool.random() ? "Left" : "Right") : "None",
    //                exercise: randomExercise
    //            )
    //            randomExercise.logs?.append(log)
    //            modelContext.insert(log)
    //        }
    //
    //        // Save context
    //        try? modelContext.save()
    //
    //        print("Dummy data created: 28 exercises and 500 logs.")
    //    }
    
    
}
