//
//  ContentView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/18/23.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @AppStorage("currentTab") var currentTab: Int = 0
    
    var body: some View {
        TabView(selection: $currentTab) {
            CurrentExerciseView()
                .tabItem {
                    Label("Exercise", systemImage: "figure.core.training")
                }
                .tag(0)
            RepertoireView()
                .tabItem {
                    Label("Repertoire", systemImage: "list.clipboard")
                }
                .tag(1)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
            currentTab = 0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
