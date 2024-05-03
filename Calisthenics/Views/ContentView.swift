import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {

    
    @Query var stashedExercises: [StashedExercise]
    
    @AppStorage("currentTab") var currentTab: Int = 0
    
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
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
            currentTab = 0
        }
    }
}

