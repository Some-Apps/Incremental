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
                    Label("First", systemImage: "1.circle")
                }
            RepertoireView()
                .tabItem {
                    Label("Second", systemImage: "2.circle")
                }
            StatsView()
                .tabItem {
                    Label("Third", systemImage: "3.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
