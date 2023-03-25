//
//  ContentView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/18/23.
//

import SwiftUI

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
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
