import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @ObservedObject private var defaultsManager = DefaultsManager()
    
    @Query var stashedExercises: [StashedExercise]
    @Query var allExercises: [Exercise]
    
    @State private var showInstructions: Bool = false

    @AppStorage("firstLaunch") var firstLaunch: Bool = true

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
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
            currentTab = 0
            
            defaultsManager.loadSettings()
            
            
            if let randomExerciseUUID = UUID(uuidString: defaultsManager.getDataFromiCloud(key: "randomExercise") as! String),
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
    }
    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        print("LOGG: \(id.description)")
        print("LOGG: \(exercises)")
        
        return exercises.first(where: { $0.id!.description == id.description })
    }
}

