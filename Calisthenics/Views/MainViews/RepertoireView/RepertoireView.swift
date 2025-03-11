import SwiftUI
import SwiftData
import TipKit

struct RepertoireView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var defaultsManager = DefaultsManager()

    @Query(filter: #Predicate<Exercise> {item in
        item.isActive ?? true
    }, sort: \.title) var activeExercises: [Exercise]

    @Query(filter: #Predicate<Exercise> { item in
        item.isActive != true ?? false
    }, sort: \.title) var inactiveExercises: [Exercise]

    @Environment(\.editMode) private var editMode
    @AppStorage("randomExercise") var randomExercise: String = ""

    let addExerciseTip = AddExerciseTip()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(activeExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            HStack {
                                Text(exercise.title ?? "Unknown")
                                Spacer()
                                if isSubscribed {
                                    if let change = oneYearChange(exercise: exercise), change.percentage != 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: change.percentage >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                                .foregroundColor(change.percentage >= 0 ? .green : .red)
                                                .opacity(0.5)
                                            Text(String(format: "%.0f%%", abs(change.percentage)))
                                                .foregroundColor(change.percentage >= 0 ? .green : .red)
                                                .opacity(0.5)
                                        }
                                    }


                                }
                                
                            }

                        }
                    }
                } header: {
                    HStack {
                        Text("Active")
                            .foregroundStyle(colorScheme.current.secondaryText)
                        Spacer()

                        if isSubscribed {
                            Text("Year Change")
                                .foregroundStyle(colorScheme.current.secondaryText)
                        }
                        
                    }
                    
                }
                .listRowBackground(colorScheme.current.secondaryBackground)

                Section {
                    ForEach(inactiveExercises, id: \.self) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            HStack {
                                Text(exercise.title ?? "Unknown")
                                Spacer()
                                if isSubscribed {
                                    if let change = oneYearChange(exercise: exercise), change.percentage != 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: change.percentage >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                                .foregroundColor(change.percentage >= 0 ? .green : .red)
                                                .opacity(0.5)
                                            Text(String(format: "%.0f%%", abs(change.percentage)))
                                                .foregroundColor(change.percentage >= 0 ? .green : .red)
                                                .opacity(0.5)
                                        }
                                    }


                                }
                                
                            }
                        }
                    }
                    // Assuming you want the same delete behavior for inactive exercises
                } header: {
                    Text("Inactive")
                        .foregroundStyle(colorScheme.current.secondaryText)

                }
                .listRowBackground(colorScheme.current.secondaryBackground)

            }
            .listStyle(.automatic)
            .scrollContentBackground(.hidden)
            .background(colorScheme.current.primaryBackground)
            .foregroundStyle(colorScheme.current.primaryText, colorScheme.current.secondaryText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        AddExerciseView()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popoverTip(addExerciseTip)
                    .onTapGesture {
                        addExerciseTip.invalidate(reason: .actionPerformed)
                    }
                }
            }
        }
        .background(colorScheme.current.primaryBackground)
    }
    
    func sortedLogs(exercise: Exercise) -> [Log] {
        let logsArray = exercise.logs ?? []
        return logsArray.sorted {
            ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast)
        }
    }

    func calculateChange(exercise: Exercise) -> (percentage: Double, change: Int)? {
        let now = Date()
        guard let currentReps = exercise.currentReps else { return nil }
        
        let logs = sortedLogs(exercise: exercise)
        guard !logs.isEmpty else { return nil }
        
        let earliestLogDate = logs.first?.timestamp ?? now
        let oneYearAgo = now.addingTimeInterval(-365 * 24 * 60 * 60)
        
        // Determine the target date based on user's data span
        let targetDate = max(oneYearAgo, earliestLogDate)
        
        // Find the log closest to the target date
        let targetLog = logs.min(by: {
            abs(($0.timestamp ?? Date()).timeIntervalSince(targetDate)) < abs(($1.timestamp ?? Date()).timeIntervalSince(targetDate))
        })
        
        guard let previousReps = targetLog?.reps else { return nil }
        guard previousReps != 0 else { return nil } // Avoid division by zero
        
        let change = Int(currentReps) - Int(previousReps)
        let percentage = (Double(change) / Double(previousReps)) * 100
        return (percentage: percentage, change: Int(change))
    }


    func oneYearChange(exercise: Exercise) -> (percentage: Double, change: Int)? {
        return calculateChange(exercise: exercise)
    }



}
