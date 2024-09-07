import SwiftData
import SwiftUI
import Charts

struct StatsView: View {
    @Query(filter: #Predicate<Exercise> { item in
        true
    }, sort: \.title) var exercises: [Exercise]
    @Query(filter: #Predicate<Log> { item in
        true
    }, sort: \.timestamp) var logs: [Log]
    
    // Function to group logs by day and calculate total duration per day
    private func timeSpentPerDay() -> [(date: Date, totalDuration: Int)] {
        let calendar = Calendar.current
        let groupedLogs = Dictionary(grouping: logs) { log -> Date in
            return calendar.startOfDay(for: log.timestamp ?? Date())
        }
        
        // Calculate total duration for each day
        let timePerDay = groupedLogs.map { (date, logsForDay) in
            let totalDuration = logsForDay.reduce(0) { $0 + Int($1.duration ?? 0) }
            return (date: date, totalDuration: totalDuration)
        }
        
        // Sort by date
        return timePerDay.sorted { $0.date < $1.date }
    }
    
    // Calculate total exercise time across all logs
    private var totalExerciseTime: Int {
        logs.reduce(0) { $0 + Int($1.duration ?? 0) }
    }
    
    // Calculate average time per day exercising
    private var averageTimePerDay: Double {
        let daysExercised = timeSpentPerDay().count
        guard daysExercised > 0 else { return 0 }
        return Double(totalExerciseTime) / Double(daysExercised)
    }
    
    private func formatTotalExerciseTime(_ totalSeconds: Int) -> String {
        let days = totalSeconds / (3600 * 24)
        let hours = (totalSeconds % (3600 * 24)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        func unitString(_ value: Int, singular: String, plural: String) -> String {
            return value == 1 ? singular : plural
        }

        if days > 0 {
            if hours > 0 {
                return "\(days) \(unitString(days, singular: "day", plural: "days")) \(hours) \(unitString(hours, singular: "hour", plural: "hours"))"
            } else {
                return "\(days) \(unitString(days, singular: "day", plural: "days")) \(minutes) \(unitString(minutes, singular: "minute", plural: "minutes"))"
            }
        } else if hours > 0 {
            if minutes > 0 {
                return "\(hours) \(unitString(hours, singular: "hour", plural: "hours")) \(minutes) \(unitString(minutes, singular: "minute", plural: "minutes"))"
            } else {
                return "\(hours) \(unitString(hours, singular: "hour", plural: "hours")) \(seconds) \(unitString(seconds, singular: "second", plural: "seconds"))"
            }
        } else if minutes > 0 {
            if seconds > 0 {
                return "\(minutes) \(unitString(minutes, singular: "minute", plural: "minutes")) \(seconds) \(unitString(seconds, singular: "second", plural: "seconds"))"
            } else {
                return "\(minutes) \(unitString(minutes, singular: "minute", plural: "minutes"))"
            }
        } else {
            return "\(seconds) \(unitString(seconds, singular: "second", plural: "seconds"))"
        }
    }

    
    var body: some View {
        Form {
            // Time Spent Per Day Chart
            Section(header: Text("Time Spent Per Day")) {
                Chart(timeSpentPerDay(), id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Total Time (sec)", item.totalDuration)
                    )
                    .annotation {
                        Text(formatDuration(item.totalDuration))
                    }
                }
                .chartXAxisLabel("Date")
                .chartYAxisLabel("Total Duration (Seconds)")
                .frame(height: 300)
            }
            
            // Total Exercise Time
            Section {
                Text("Total Time: \(formatTotalExerciseTime(totalExerciseTime))")
                
                Text("Total Sets Completed: \(logs.count)")
//                Text("Average Time Per Day Exercising: \(String(format: "%.2f", averageTimePerDay)) seconds")
                
            }
        }
        .navigationTitle("Exercise Stats")
    }
    
    // Helper function to format duration in MM:SS or HH:MM:SS
    private func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}



#Preview {
    StatsView()
}
