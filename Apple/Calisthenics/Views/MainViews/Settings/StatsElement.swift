import SwiftData
import SwiftUI
import Charts

struct StatsElement: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

    @Query(filter: #Predicate<Exercise> { item in
        true
    }, sort: \.title) var exercises: [Exercise]
    @Query(filter: #Predicate<Log> { item in
        true
    }, sort: \.timestamp) var logs: [Log]
    
    // Function to group logs by day and calculate total duration per day in minutes
    private func timeSpentPerDay() -> [(date: Date, totalDuration: Int)] {
        let calendar = Calendar.current
        let groupedLogs = Dictionary(grouping: logs) { log -> Date in
            return calendar.startOfDay(for: log.timestamp ?? Date())
        }
        
        // Calculate total duration for each day in minutes
        let timePerDay = groupedLogs.map { (date, logsForDay) in
            let totalDuration = logsForDay.reduce(0) { $0 + Int($1.duration ?? 0) } / 60
            return (date: date, totalDuration: totalDuration)
        }
        
        // Sort by date
        return timePerDay.sorted { $0.date < $1.date }
    }
    
    // Calculate total exercise time across all logs
    private var totalExerciseTime: Int {
        logs.reduce(0) { $0 + Int($1.duration ?? 0) } / 60  // In minutes
    }
    
    // Show or hide chart based on available data
    private var showChart: Bool {
        timeSpentPerDay().count > 1
    }

    var body: some View {
        if showChart {
            Chart {
                ForEach(timeSpentPerDay(), id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Total Time (min)", item.totalDuration)
                    )
                }
            }
            .chartXAxisLabel("Date")
            .chartYAxisLabel("Total Duration (Minutes)")
            .frame(height: 300)
        } else {
//            Text("No data available")
        }

        Text("Total Time: ") +
        Text("\(formatTotalExerciseTime(totalExerciseTime))")
            .foregroundStyle(colorScheme.current.secondaryText)
        Text("Total Sets Completed: ") +
             Text("\(logs.count)")
            .foregroundStyle(colorScheme.current.secondaryText)
    }

    private func formatTotalExerciseTime(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours) \(hours == 1 ? "hour" : "hours") \(minutes) \(minutes == 1 ? "minute" : "minutes")"
        } else {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
        }
    }
}



#Preview {
    StatsElement()
}
