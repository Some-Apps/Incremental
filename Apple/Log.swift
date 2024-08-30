import Foundation
import SwiftData

@Model class Log {
    var duration: Int16? = 0
    var id: UUID?
    var reps: Double? = 0
    var timestamp: Date?
    var units: String?
    var difficulty: String?
    var exercise: Exercise?
    
    init(duration: Int16, id: UUID, reps: Double, timestamp: Date, units: String, difficulty: String, exercise: Exercise) {
        self.duration = duration
        self.id = id
        self.reps = reps
        self.timestamp = timestamp
        self.units = units
        self.difficulty = difficulty
        self.exercise = exercise
    }
}
