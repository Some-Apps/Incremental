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
            ExercisesView()
                .tabItem {
                    Label("First", systemImage: "1.circle")
                }
            RepertoireView()
                .tabItem {
                    Label("Second", systemImage: "2.circle")
                }
            SettingsView()
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
