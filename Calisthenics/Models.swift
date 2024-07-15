import Foundation

let muscleOptions = ["Abductors", "Abs", "Adductors", "Back", "Biceps", "Calves", "Chest", "Forearms", "Glutes", "Hamstrings", "Lower Back", "Neck", "Quadriceps", "Shoulders", "Triceps", "Trapezius"]

let unitOptions = ["Reps", "Duration"]

enum Difficulty: String, CaseIterable {
    case easy, hard
}

enum Units: String, CaseIterable {
    case reps, duration
}
