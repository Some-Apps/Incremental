//
//  ExerciseViewModel.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/6/23.
//

import CoreData
import SwiftUI
import Foundation

class ExerciseViewModel: ObservableObject {
    @Published var exercise: Exercise? = nil
    @Published var difficulty: Difficulty = .medium

    @AppStorage("randomExercise") var randomExercise: String = ""

    let moc = PersistenceController.shared.container.viewContext

    func fetchExercise() {
        guard !randomExercise.isEmpty else { return }
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", randomExercise)
        do {
            let result = try moc.fetch(request)
            if let fetchedExercise = result.first {
                DispatchQueue.main.async {
                    self.difficulty = Difficulty(rawValue: fetchedExercise.difficulty!) ?? .medium
                    self.exercise = fetchedExercise
                }
            } else {
                // Exercise with the provided UUID not found.
                // Generate a new random exercise.
                generateRandomExercise()
            }
        } catch {
            print("Failed to fetch exercise: \(error)")
        }
    }

    func generateRandomExercise() {
        // your implementation here
    }
}
