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
    
    @State private var showPopover = false
    @State private var tempDifficulty: Difficulty = .medium
    
    @AppStorage("randomExercise") var randomExercise: String = ""
    
    @Query(filter: #Predicate<Exercise> { item in
        item.isActive == true
    }) var exercises: [Exercise]
    
    var body: some View {
        ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(colorScheme == .light ? .white : .black)
                    .shadow(color: colorScheme == .light ? .black.opacity(0.33) : .white, radius: 3)
                VStack {
                    HStack {
                        Text(fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: exercises)!.title!)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .onAppear {
                                exerciseViewModel.exercise = fetchExerciseById(id: UUID(uuidString: randomExercise)!, exercises: exercises)
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
                    case .medium:
                        Text("Had to pause but didn't have to take a break")
                            .foregroundColor(.secondary)
                    case .hard:
                        Text("Had to take a break or 3 pauses")
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
