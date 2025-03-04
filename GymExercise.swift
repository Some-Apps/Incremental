import Foundation
import SwiftData

@Model class GymExercise {
    var currentReps: Double?
    var currentSets: Int?
    var difficulty: String?
    var id: UUID?
    var isActive: Bool?
    var notes: String?
    var title: String?
    var minWeightChange: Int?
    
    var increment: Double?
    var incrementIncrement: Double?
    @Relationship(inverse: \Log.exercise) var logs: [Log]?
    
    init(currentReps: Double, currentSets: Int, difficulty: String, id: UUID, isActive: Bool, notes: String, title: String, increment: Double, incrementIncrement: Double, logs: [Log]) {
        self.currentReps = currentReps
        self.currentSets = currentSets
        self.difficulty = difficulty
        self.id = id
        self.isActive = isActive
        self.notes = notes
        self.title = title
        self.increment = increment
        self.incrementIncrement = incrementIncrement
        self.logs = logs
    }
}
