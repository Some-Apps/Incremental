import Foundation
import SwiftData

@Model class Exercise {
    var currentReps: Double?
    var difficulty: String?
    var id: UUID?
    var isActive: Bool?
    var notes: String?
    var title: String?
    var units: String?
    var increment: Double?
    var incrementIncrement: Double?
    var leftRight: Bool?
    var leftSide: Bool?
    @Relationship(inverse: \Log.exercise) var logs: [Log]?
    @Relationship(inverse: \Muscle.exercises) var muscles: [Muscle]?
    
    init(currentReps: Double, difficulty: String, id: UUID, isActive: Bool, notes: String, title: String, units: String, increment: Double, incrementIncrement: Double, leftRight: Bool, leftSide: Bool, logs: [Log], muscles: [Muscle]) {
        self.currentReps = currentReps
        self.difficulty = difficulty
        self.id = id
        self.isActive = isActive
        self.notes = notes
        self.title = title
        self.units = units
        self.increment = increment
        self.incrementIncrement = incrementIncrement
        self.leftRight = leftRight
        self.leftSide = leftSide
        self.logs = logs
        self.muscles = muscles
    }
}

@Model class StashedExercise {
    var currentReps: Double?
    var difficulty: String?
    var id: UUID?
    var isActive: Bool?
    var notes: String?
    var title: String?
    var units: String?
    var increment: Double?
    var incrementIncrement: Double?
    var leftRight: Bool?
    var leftSide: Bool?
    init(currentReps: Double, difficulty: String, id: UUID, isActive: Bool, notes: String, title: String, units: String, increment: Double, incrementIncrement: Double, leftRight: Bool, leftSide: Bool) {
        self.currentReps = currentReps
        self.difficulty = difficulty
        self.id = id
        self.isActive = isActive
        self.notes = notes
        self.title = title
        self.units = units
        self.increment = increment
        self.incrementIncrement = incrementIncrement
        self.leftRight = leftRight
        self.leftSide = leftSide
    }
}
