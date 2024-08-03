//
//  Muscle.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/4/24.
//
//

import Foundation
import SwiftData


@Model class Muscle {
    var id: UUID?
    var muscle: String?
    var exercises: [Exercise]?
    
    init(id: UUID, muscle: String, exercises: [Exercise]) {
        self.id = id
        self.muscle = muscle
        self.exercises = exercises
    }
}
