//
//  ExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI

struct ExerciseCardView: View {
    let exercise: Exercise
    let seconds: Int
    
    @Binding var difficulty: Difficulty
    @Binding var finishedTapped: Bool
    @Binding var isRunning: Bool
    
    @State private var showPopover = false
    
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 3)
                VStack {
                    HStack {
                        Text(exercise.title!)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                        if exercise.notes?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                            Button {
                                showPopover.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .popover(isPresented: $showPopover, content: {
                                Text(exercise.notes!)
                                    .padding()
                            })
                        }
                        
                    }
                    
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
                    Divider()
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(isRunning)
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
                    Button("Finish") {
                        finishedTapped = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .font(.title)
                    .disabled(seconds < 5 || isRunning)
                }
                .padding()
            }
            .padding()
        }
    }
}



//struct ExerciseCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseCardView(exercise: Exercise.preview())
//    }
//}
