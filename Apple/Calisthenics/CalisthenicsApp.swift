//import FirebaseCore
import SwiftUI
import SwiftData
import TipKit

@main
struct CalisthenicsApp: App {
    @StateObject var colorSchemeState = ColorSchemeState()
    @AppStorage("showTips") var showTips: Bool = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Log.self,
            Exercise.self,
            StashedExercise.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)
                    ])
                }
                .environmentObject(colorSchemeState)
        }
        .modelContainer(sharedModelContainer)
    }

    
}
