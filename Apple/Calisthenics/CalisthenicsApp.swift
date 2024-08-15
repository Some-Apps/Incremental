import SwiftUI
import SwiftData

@main
struct CalisthenicsApp: App {
    
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
        
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Log.self,
            Exercise.self,
            StashedExercise.self,
            Muscle.self
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
        }
        .modelContainer(sharedModelContainer)
    }
}
