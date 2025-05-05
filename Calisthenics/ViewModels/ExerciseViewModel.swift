import AlertToast
import CoreData
import SwiftUI
import WidgetKit
import SwiftData

class ExerciseViewModel: ObservableObject {
    static let shared = ExerciseViewModel(stopwatchViewModel: StopwatchViewModel.shared)
    @Environment(\.modelContext) var modelContext
    
    @Published var exercise: Exercise? = nil {
        didSet {
            difficulty = Difficulty(rawValue: exercise?.difficulty ?? "easy") ?? .easy
            print("[LOG] Difficulty: \(String(describing: exercise?.difficulty))")
        }
    }

    @Published var difficulty: Difficulty = .easy
    @Published var isLoading = true

    let stopwatchViewModel: StopwatchViewModel
    
    init(stopwatchViewModel: StopwatchViewModel) {
        self.stopwatchViewModel = stopwatchViewModel
    }
}

class StashedExerciseViewModel: ObservableObject {
    static let shared = StashedExerciseViewModel(stopwatchViewModel: StopwatchViewModel.shared)
    @Environment(\.modelContext) var modelContext
    
    @Published var exercise: StashedExercise? = nil
    @Published var difficulty: Difficulty = .easy
    @Published var isLoading = true

    let stopwatchViewModel: StopwatchViewModel
    
    init(stopwatchViewModel: StopwatchViewModel) {
        self.stopwatchViewModel = stopwatchViewModel
    }
    
}
