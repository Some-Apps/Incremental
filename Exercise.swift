//
//  Exercise.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/4/24.
//
//

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
    @Relationship(inverse: \Log.exercises) var logs: [Log]?
    @Relationship(inverse: \Muscle.exercises) var muscles: [Muscle]?
    
    init(currentReps: Double, difficulty: String, id: UUID, isActive: Bool, notes: String, title: String, units: String, increment: Double, incrementIncrement: Double, logs: [Log], muscles: [Muscle]) {
        self.currentReps = currentReps
        self.difficulty = difficulty
        self.id = id
        self.isActive = isActive
        self.notes = notes
        self.title = title
        self.units = units
        self.increment = increment
        self.incrementIncrement = incrementIncrement
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
    init(currentReps: Double, difficulty: String, id: UUID, isActive: Bool, notes: String, title: String, units: String, increment: Double, incrementIncrement: Double) {
        self.currentReps = currentReps
        self.difficulty = difficulty
        self.id = id
        self.isActive = isActive
        self.notes = notes
        self.title = title
        self.units = units
        self.increment = increment
        self.incrementIncrement = incrementIncrement
    }
}
