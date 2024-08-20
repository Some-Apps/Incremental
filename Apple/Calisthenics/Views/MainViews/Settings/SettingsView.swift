import SwiftUI

struct SettingsView: View {
    @AppStorage("healthActivityCategory") var healthActivityCategory: String = "Functional Strength Training"
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    let activityCategories = ["Core Training", "Functional Strength Training", "High-Intensity Interval Training", "Mixed Cardio", "Other", "Traditional Strength Training"]
    
    var body: some View {
        Group {
            if idiom == .pad || idiom == .mac {
                NavigationStack {
                    formContent
                }
            } else {
                NavigationView {
                    formContent
                        .navigationTitle("Settings")
                }
            }
        }
    }
    
    private var formContent: some View {
        Form {
            Section {
                NavigationLink("How To Use App", destination: TutorialView())
                NavigationLink("Exercise History", destination: ExerciseHistoryView())
                NavigationLink("Progression Photos", destination: ProgressionPhotosView())
            }
            Section {
                Picker("Health Category", selection: $healthActivityCategory) {
                    ForEach(activityCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
    }
}
