//
//  CalisthenicsApp.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/18/23.
//

import SwiftUI

@main
struct CalisthenicsApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
