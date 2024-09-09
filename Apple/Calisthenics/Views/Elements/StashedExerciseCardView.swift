//
//  StashedExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 5/3/24.
//

import SwiftUI
import SwiftData

struct StashedExerciseCardView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

    @Environment(\.modelContext) var modelContext
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = StashedExerciseViewModel.shared
    
    @Binding var finishedTapped: Bool
    @Binding var stashedExercise: Bool
    
    @State private var showPopover = false
    @Binding var tempDifficulty: Difficulty

        
    @Query var exercises: [StashedExercise]
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(colorScheme.current.primaryBackground)
                    .shadow(color: colorScheme.current.primaryText.opacity(0.5), radius: 2)
                VStack {
                    HStack {
                        Text("\(exercises.first?.title ?? "")\((exercises.first?.leftRight ?? false) ? (exercises.first?.leftSide ?? false ? " (left)" : " (right)") : "")")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(colorScheme.current.secondaryText)
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
                        Text("Didn't have to pause")
                            .foregroundStyle(colorScheme.current.secondaryText)
                    case .hard:
                        Text("Had to pause")
                            .foregroundStyle(colorScheme.current.secondaryText)
                    }
                      
                    Button("Finish") {
                        finishedTapped = true
                    }
                    .buttonStyle(.bordered)
                    .tint(colorScheme.current.successButton)
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
