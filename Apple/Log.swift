import Foundation
import SwiftData

@Model class Log {
    var duration: Int16? = 0
    var id: UUID?
    var reps: Double? = 0
    var timestamp: Date?
    var units: String?
    var difficulty: String?
    var side: String?
    var exercise: Exercise?
    var exerciseId: UUID?
    
    init(duration: Int16, id: UUID, reps: Double, timestamp: Date, units: String, difficulty: String, side: String, exercise: Exercise) {
        self.duration = duration
        self.id = id
        self.reps = reps
        self.timestamp = timestamp
        self.units = units
        self.difficulty = difficulty
        self.side = side
        self.exercise = exercise
        self.exerciseId = exercise.id
    }
}
