//
//  ExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) var modelContext
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = ExerciseViewModel.shared
    
    @Binding var finishedTapped: Bool
    @Binding var stashedExercise: Bool
    @State private var leftRightText = ""
    @State private var showPopover = false
    @Binding var tempDifficulty: Difficulty
    @Query var stashedExercises: [StashedExercise]

    
    @AppStorage("randomExercise") var randomExercise: String = ""
    
    
    @Query(filter: #Predicate<Exercise> { item in
        item.isActive == true
    }) var exercises: [Exercise]
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(colorScheme == .light ? .white : .black)
                    .shadow(color: colorScheme == .light ? .black.opacity(0.33) : .white.opacity(0.33), radius: 3)
                VStack {
                    HStack {
                        
                        Text((fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: exercises)?.title ?? "") + ((exerciseViewModel.exercise?.leftRight ?? false) ? ((exerciseViewModel.exercise?.leftSide ?? false) ? " (left)" : " (right)") : ""))
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.secondary)
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
                    } else if exerciseViewModel.exercise!.units == "Duration" {
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
                            .foregroundColor(.secondary)
                    case .hard:
                        Text("Had to pause")
                            .foregroundColor(.secondary)
                    }
                    Button("Finish") {
                        finishedTapped = true
                        
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .font(.title)
                    .disabled(stopwatchViewModel.seconds < 5 || stopwatchViewModel.isRunning)
                    if stashedExercises.count < 10 {
                        Button("Stash Exercise") {
                            if let exercise = exerciseViewModel.exercise {
                                let tempExercise = StashedExercise(currentReps: exercise.currentReps!, difficulty: exercise.difficulty!, id: exercise.id!, isActive: exercise.isActive!, notes: exercise.notes!, title: exercise.title!, units: exercise.units!, increment: exercise.increment ?? 0, incrementIncrement: exercise.incrementIncrement ?? 0, leftRight: exercise.leftRight ?? false, leftSide: exercise.leftSide ?? true)
                                modelContext.insert(tempExercise)
                                try? modelContext.save()
                                stashedExercise = true
                            }
                            
                        }
                        .disabled(stopwatchViewModel.seconds >= 5 || stashedExercise)
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
        print("LOGG: \(id.description)")
        print("LOGG: \(exercises)")
        
        return exercises.first(where: { $0.id!.description == id.description })
    }
    
}



//struct ExerciseCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseCardView(exercise: Exercise.preview())
//    }
//}
