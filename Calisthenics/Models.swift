import Foundation

let unitOptions = ["Reps", "Duration"]

enum Difficulty: String, CaseIterable {
    case easy, hard
}

enum Units: String, CaseIterable {
    case reps, duration
}
