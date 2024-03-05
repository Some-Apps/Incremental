//
//  CalisthenicsApp.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/18/23.
//

import SwiftUI
import SwiftData

@main
struct CalisthenicsApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Log.self)
        .modelContainer(for: Exercise.self)
        .modelContainer(for: Muscle.self)
    }
}
