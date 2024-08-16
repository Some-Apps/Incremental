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
                                Text(log.exercises?.title ?? "Unknown")
                                Spacer()
                                if log.exercises?.units == "Reps" {
                                    Text("\(log.reps ?? 0)")
                                } else {
                                    Text(String(format: "%01d:%02d", (log.reps ?? 0) / 60, (log.reps ?? 0) % 60))
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

