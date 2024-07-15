import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Log.timestamp, order: .reverse) var logs: [Log]
    
    var groupedLogs: [String: [Log]] {
        Dictionary(grouping: logs) { log in
            let logDate = Calendar.current.startOfDay(for: log.timestamp ?? Date())
            if Calendar.current.isDateInToday(logDate) {
                return "Today"
            } else {
                return DateFormatter.localizedString(from: logDate, dateStyle: .medium, timeStyle: .none)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(groupedLogs.keys.sorted(by: { $0 > $1 }), id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(groupedLogs[key] ?? [], id: \.self) { log in
                        HStack {
                            Text(log.exercises?.title ?? "Unknown")
                            Spacer()
                            if log.exercises?.units == "Reps" {
//                                Text("hi")
                                Text("\(log.reps ?? 0)")
                            } else {
                                Text(String(format: "%01d:%02d", (log.reps ?? 0) / 60, (log.reps ?? 0) % 60))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Exercise History")
    }
}
