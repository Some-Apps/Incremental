import SwiftUI

struct SettingsView: View {
    @ObservedObject private var defaultsManager = DefaultsManager()
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    @AppStorage("easyType") var easyType = "Increment"
    @AppStorage("easyText") var easyText = "Didn't have to pause"
    @AppStorage("easyIncrement") var easyIncrement = 0.5
    @AppStorage("easyPercent") var easyPercent = 0.5
    
    @AppStorage("mediumType") var mediumType = "Increment"
    @AppStorage("mediumText") var mediumText = "Had to pause but didn't have to take a break"
    @AppStorage("mediumIncrement") var mediumIncrement =  0.1
    @AppStorage("mediumPercent") var mediumPercent = 0.1
    
    @AppStorage("hardType") var hardType = "Increment"
    @AppStorage("hardText") var hardText = "Had to take a break or 3 pauses"
    @AppStorage("hardIncrement") var hardIncrement = -2.0
    @AppStorage("hardPercent") var hardPercent = -5.0
    
    @AppStorage("maxStashed") var maxStashed = 10
    
    @State private var tempEasyType = "Increment"
    @State private var tempMediumType = "Increment"
    @State private var tempHardType = "Increment"
    @State private var tempEasyText = "Didn't have to pause"
    @State private var tempMediumText = "Didn't have to pause"
    @State private var tempHardText = "Didn't have to pause"
    @State private var tempEasyPercent = 0.5
    @State private var tempMediumPercent = 0.1
    @State private var tempHardPercent = -5.0
    @State private var tempEasyIncrement = 0.5
    @State private var tempMediumIncrement = 0.1
    @State private var tempHardIncrement = -2.0
    @State private var tempmMaxStashed: Int = 10

    
    @AppStorage("holdDuration") var holdDuration: Double = 0
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate
    
    @State private var confirmSaveSettings = false
    
    let typeOptions = ["Percent", "Increment"]
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
