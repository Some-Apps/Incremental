//
//  Log.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/4/24.
//
//

import Foundation
import SwiftData

@Model class Log {
    var duration: Int16? = 0
    var id: UUID?
    var reps: Int16? = 0
    var timestamp: Date?
    var units: String?
    var exercise: Exercise?
    
    init(duration: Int16, id: UUID, reps: Int16, timestamp: Date, units: String, exercise: Exercise) {
        self.duration = duration
        self.id = id
        self.reps = reps
        self.timestamp = timestamp
        self.units = units
        self.exercise = exercise
    }
}
