import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {

    
    @Query var stashedExercises: [StashedExercise]
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
        }
    }
}

