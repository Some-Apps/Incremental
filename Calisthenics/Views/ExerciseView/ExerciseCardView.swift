//
//  ExerciseCardView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI

struct ExerciseCardView: View {
    @StateObject var stopwatchViewModel = StopwatchViewModel.shared
    @StateObject var exerciseViewModel = ExerciseViewModel.shared
    
    @Binding var finishedTapped: Bool
    
    @State private var showPopover = false
    @State private var tempDifficulty: Difficulty = .medium
    
    @AppStorage("randomExercise") var randomExercise: String = ""
    
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isActive == %@", NSNumber(value: true))
    ) var exercises: FetchedResults<Exercise>
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 3)
                VStack {
                    HStack {
                        Text(exerciseViewModel.fetchExerciseById(id: UUID(uuidString: randomExercise)!)!.title!)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                            .onAppear {
                                exerciseViewModel.exercise = exerciseViewModel.fetchExerciseById(id: UUID(uuidString: randomExercise)!)
                            }
                        if exerciseViewModel.exercise!.notes?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
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
                        Text(String(Int(exerciseViewModel.exercise!.currentReps)))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    } else if exerciseViewModel.exercise!.units == "Duration" {
                        Text(String(format: "%01d:%02d", Int(exerciseViewModel.exercise!.currentReps) / 60, Int(exerciseViewModel.exercise!.currentReps) % 60))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    }
                    Divider()
                    Picker("Difficulty", selection: $tempDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .onChange(of: tempDifficulty) { newValue in
                        exerciseViewModel.difficulty = tempDifficulty
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(stopwatchViewModel.isRunning)
                    switch exerciseViewModel.difficulty {
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
                    .disabled(stopwatchViewModel.seconds < 5 || stopwatchViewModel.isRunning)
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



//struct ExerciseCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseCardView(exercise: Exercise.preview())
//    }
//}
