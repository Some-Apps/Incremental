import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var logs: [Log] = []
    @State private var groupedLogs: [Date: [Log]] = [:]
    @State private var isLoading = true

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading...")
            } else {
                ForEach(groupedLogs.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                    Section(header: Text(headerTitle(for: date))) {
                        ForEach(groupedLogs[date] ?? [], id: \.self) { log in
                            HStack {
                                Text("\(log.exercise?.title ?? "Unknown")")
                                if let side = log.side {
                                    Image(systemName: side == "right" ? "arrowshape.right" : side == "left" ? "arrowshape.left" : "")
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if log.exercise?.units == "Reps" {
                                    Text("\(Int(log.reps ?? 0))")
                                } else {
                                    if let reps = log.reps {
                                        let minutes = Int(reps) / 60
                                        let seconds = Int(reps) % 60
                                        Text(String(format: "%01d:%02d", minutes, seconds))
                                    } else {
                                        Text("0:00")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Exercise History")
        .onAppear(perform: loadLogs)
    }

    private func loadLogs() {
        DispatchQueue.global(qos: .background).async {
            let fetchDescriptor = FetchDescriptor<Log>(
                sortBy: [SortDescriptor(\Log.timestamp, order: .reverse)]
            )
            do {
                let fetchedLogs = try modelContext.fetch(fetchDescriptor)
                for log in fetchedLogs {
                    if log.exercise == nil, let exerciseId = log.exerciseId {
                        // Try to fetch the missing Exercise by its ID
                        let exerciseFetchDescriptor = FetchDescriptor<Exercise>(
                            predicate: #Predicate { $0.id == exerciseId }
                        )
                        if let fetchedExercise = try? modelContext.fetch(exerciseFetchDescriptor).first {
                            log.exercise = fetchedExercise  // Re-link the exercise
                        }
                    }
                }
                
                let grouped = Dictionary(grouping: fetchedLogs) { log -> Date in
                    return Calendar.current.startOfDay(for: log.timestamp ?? Date())
                }
                DispatchQueue.main.async {
                    self.logs = fetchedLogs
                    self.groupedLogs = grouped
                    self.isLoading = false
                }
            } catch {
                print("Failed to load Log model: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }


    private func headerTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }
    }
}

