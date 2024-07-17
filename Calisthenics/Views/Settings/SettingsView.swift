import SwiftUI

struct SettingsView: View {
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        if idiom == .pad || idiom == .mac {
            NavigationStack {
                Form {
                    Section {
                        NavigationLink("How To Use App", destination: TutorialView())
                        NavigationLink("Exercise History", destination: ExerciseHistoryView())
                    }
                }
            }
        } else {
            NavigationView {
                Form {
                    Section {
                        NavigationLink("How To Use App", destination: TutorialView())
                        NavigationLink("Exercise History", destination: ExerciseHistoryView())
                    }
                }
            }
        }
        
    }
}
