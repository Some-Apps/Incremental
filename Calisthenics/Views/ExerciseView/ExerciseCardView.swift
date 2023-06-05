//
//  ExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI

struct ExerciseCardView: View {
    let exercise: Exercise
    
    @Binding var difficulty: Difficulty
    
    var body: some View {
        VStack {
            Text(exercise.title!)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.secondary)
            Divider()
            if exercise.units == "Reps" {
                Text(String(Int(exercise.currentReps)))
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            } else if exercise.units == "Duration" {
                Text(String(format: "%01d:%02d", Int(exercise.currentReps) / 60, Int(exercise.currentReps) % 60))
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
//            if exercise.notes!.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
//                Divider()
//                Text(exercise.notes!)
//                    .italic()
//            }
            Divider()
            Picker("Difficulty", selection: $difficulty) {
                ForEach(Difficulty.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            switch difficulty {
            case .easy:
                Text("Didn't have to pause")
                    .foregroundColor(.secondary)
            case .medium:
                Text("Had to pause but didn't have to take a break")
                    .foregroundColor(.secondary)
            case .hard:
                Text("Had to take a break")
                    .foregroundColor(.secondary)
            }
        }
    }
}


//struct ExerciseCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseCardView(exercise: Exercise.preview())
//    }
//}
