//
//  ExerciseView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import Charts
import SwiftUI

struct ExerciseView: View {
    let exercise: Exercise
    
    var sortedLogs: [Log] {
        let logsArray = exercise.logs?.allObjects as? [Log] ?? []
        return logsArray.sorted { $0.timestamp! < $1.timestamp! }
    }
    
    var body: some View {
        VStack {
            Text(exercise.title!)
            Form {
                Chart(sortedLogs, id: \.self) { log in
                    LineMark(x: .value("Date", log.timestamp!), y: .value("Reps", log.reps))
                        .interpolationMethod(.linear)
                }
                .frame(height: 200)
            }
        }
    }
}


struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(exercise: Exercise.preview())
    }
}
