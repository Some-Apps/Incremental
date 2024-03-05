//
//  ContentView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/18/23.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    
    var body: some View {
        TabView {
            CurrentExerciseView()
                .tabItem {
                    Label("Exercise", systemImage: "figure.core.training")
                }
            RepertoireView()
                .tabItem {
                    Label("Repertoire", systemImage: "list.clipboard")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
