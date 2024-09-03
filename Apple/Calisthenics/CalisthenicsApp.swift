import FirebaseCore
import SwiftUI
import SwiftData
import TipKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CalisthenicsApp: App {
        
    @AppStorage("showTips") var showTips: Bool = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Log.self,
            Exercise.self,
            StashedExercise.self,
            Muscle.self,
            PhotoProgression.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(sharedModelContainer)
    }

    
}
