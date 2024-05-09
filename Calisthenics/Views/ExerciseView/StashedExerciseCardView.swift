//
//  StashedExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 5/3/24.
//

import SwiftUI
import SwiftData

struct StashedExerciseCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) var modelContext
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = StashedExerciseViewModel.shared
    
    @Binding var finishedTapped: Bool
    @Binding var stashedExercise: Bool
    
    @State private var showPopover = false
    @Binding var tempDifficulty: Difficulty
    @AppStorage("easyText") var easyText = "Didn't have to pause"
    
    @AppStorage("mediumText") var mediumText = "Had to pause but didn't have to take a break"

    @AppStorage("hardText") var hardText = "Had to take a break or 3 pauses"
        
    @Query var exercises: [StashedExercise]
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(colorScheme == .light ? .white : .black)
                    .shadow(color: colorScheme == .light ? .black.opacity(0.33) : .white.opacity(0.33), radius: 3)
                VStack {
                    HStack {
                        Text(exercises.first?.title ?? "")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .onAppear {
                                exerciseViewModel.exercise = exercises.first
                            }
                            .onChange(of: exerciseViewModel.exercise) {
                                exerciseViewModel.exercise = exercises.first
                            }
                        if exerciseViewModel.exercise?.notes?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                            Button {
                                showPopover.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .popover(isPresented: $showPopover, content: {
                                Text(exerciseViewModel.exercise!.notes!)
                                    .padding()
                            })
                        }
                        
                    }
                    
                    Divider()
                    if exerciseViewModel.exercise?.units == "Reps" {
                        Text(String(Int(exerciseViewModel.exercise!.currentReps!)))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    } else if exerciseViewModel.exercise?.units == "Duration" {
                        Text(String(format: "%01d:%02d", Int(exerciseViewModel.exercise!.currentReps!) / 60, Int(exerciseViewModel.exercise!.currentReps!) % 60))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    }
                    Divider()
                    Picker("Difficulty", selection: $tempDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .onChange(of: tempDifficulty) {
                        exerciseViewModel.difficulty = tempDifficulty
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(stopwatchViewModel.isRunning)
                    switch exerciseViewModel.difficulty {
                    case .easy:
                        Text(easyText)
                            .foregroundColor(.secondary)
                    case .medium:
                        Text(mediumText)
                            .foregroundColor(.secondary)
                    case .hard:
                        Text(hardText)
                            .foregroundColor(.secondary)
                    }
                      
                    Button("Finish") {
                        finishedTapped = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .font(.title)
                    .disabled(stopwatchViewModel.seconds < 5 || stopwatchViewModel.isRunning)
//                    .onChange(of: finishedTapped) {
//                        if finishedTapped {
//                            exerciseViewModel.exercise = exercises.first
//                        }
//                    }
                }
                .padding()
            }
            .padding()
        }
        .onReceive(exerciseViewModel.$exercise) { exercise in
                if let fetchedExercise = exercise,
                   let difficulty = Difficulty(rawValue: fetchedExercise.difficulty!) {
                    tempDifficulty = difficulty
                }
            }
    }

}
