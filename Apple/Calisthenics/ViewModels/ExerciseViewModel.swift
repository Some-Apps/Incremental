//
//  ExerciseViewModel.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/6/23.
//

import AlertToast
import CoreData
import SwiftUI
import HealthKit
import WidgetKit
import SwiftData

class ExerciseViewModel: ObservableObject {
    static let shared = ExerciseViewModel(stopwatchViewModel: StopwatchViewModel.shared)
    @Environment(\.modelContext) var modelContext
    
    @Published var exercise: Exercise? = nil
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
