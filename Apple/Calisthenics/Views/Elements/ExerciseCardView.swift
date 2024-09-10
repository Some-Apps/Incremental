//
//  ExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

    @Environment(\.modelContext) var modelContext
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = ExerciseViewModel.shared
    
    @Binding var finishedTapped: Bool
    @Binding var stashedExercise: Bool
    @State private var leftRightText = ""
    @State private var showPopover = false
    @Binding var tempDifficulty: Difficulty
    @Query var stashedExercises: [StashedExercise]
    @State private var haptic = false
    
    @AppStorage("randomExercise") var randomExercise: String = ""
    
    
    @Query(filter: #Predicate<Exercise> { item in
        item.isActive == true
    }) var exercises: [Exercise]
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(colorScheme.current.secondaryBackground)
                    .shadow(color: colorScheme.current.primaryText.opacity(0.5), radius: 2)
                VStack {
                    HStack {
                        
                        Text((fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: exercises)?.title ?? "") + ((exerciseViewModel.exercise?.leftRight ?? false) ? ((exerciseViewModel.exercise?.leftSide ?? false) ? " (left)" : " (right)") : ""))
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(colorScheme.current.secondaryText)
                                .multilineTextAlignment(.center)
                                .onAppear {
                                    if let newExercise = fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: exercises) {
                                        exerciseViewModel.exercise = newExercise
                                    }
                                }
                        

                            
                        if exerciseViewModel.exercise!.notes!.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
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
                    if exerciseViewModel.exercise!.units == "Reps" {
                        Text(String(Int(exerciseViewModel.exercise!.currentReps!)))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(colorScheme.current.primaryText)
                    } else if exerciseViewModel.exercise!.units == "Duration" {
                        Text(String(format: "%01d:%02d", Int(exerciseViewModel.exercise!.currentReps!) / 60, Int(exerciseViewModel.exercise!.currentReps!) % 60))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(colorScheme.current.primaryText)
                    }
                    Divider()
                    Picker("Difficulty", selection: $tempDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.rawValue)
                                .foregroundStyle(colorScheme.current.primaryText)
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
                            .foregroundColor(colorScheme.current.secondaryText)
                    case .hard:
                        Text("Had to pause")
                            .foregroundColor(colorScheme.current.secondaryText)
                    }
                    Button("Finish") {
                        finishedTapped = true
                        haptic.toggle()
                    }
                    .sensoryFeedback(.success, trigger: haptic)
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .font(.title)
                    .disabled(stopwatchViewModel.seconds < 3 || stopwatchViewModel.isRunning)
                    if stashedExercises.count < 10 {
                        Button("Stash Exercise") {
                            if let exercise = exerciseViewModel.exercise {
                                let tempExercise = StashedExercise(currentReps: exercise.currentReps!, difficulty: exercise.difficulty!, id: exercise.id!, isActive: exercise.isActive!, notes: exercise.notes!, title: exercise.title!, units: exercise.units!, increment: exercise.increment ?? 0, incrementIncrement: exercise.incrementIncrement ?? 0, leftRight: exercise.leftRight ?? false, leftSide: exercise.leftSide ?? true)
                                modelContext.insert(tempExercise)
                                try? modelContext.save()
                                stashedExercise = true
                            }
                            
                        }
                        .disabled(stopwatchViewModel.seconds >= 3 || stashedExercise)
                    }
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
    func fetchExerciseById(id: UUID, exercises: [Exercise]) -> Exercise? {
        return exercises.first(where: { $0.id!.description == id.description })
    }
    
}
