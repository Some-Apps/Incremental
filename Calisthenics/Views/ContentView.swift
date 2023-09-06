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
                    Image(systemName: "figure.core.training")
                }
            RepertoireView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
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
