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
    
    @AppStorage("selectedTimeFrame") private var selectedTimeFrame: String = "All Time"

        enum TimeFrame: String, CaseIterable, Identifiable {
            case allTime = "All Time"
            case year = "Year"
            case sixMonths = "6 Months"
            case month = "Month"
            
            var id: String { self.rawValue }
        }
    private func filteredLogs() -> [Log] {
            let calendar = Calendar.current
            let now = Date()
            
            guard let timeFrame = TimeFrame(rawValue: selectedTimeFrame) else {
                return logs
            }
            
            switch timeFrame {
            case .allTime:
                return logs
            case .year:
                let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
                return logs.filter { $0.timestamp ?? Date() >= oneYearAgo }
            case .sixMonths:
                let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
                return logs.filter { $0.timestamp ?? Date() >= sixMonthsAgo }
            case .month:
                let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                return logs.filter { $0.timestamp ?? Date() >= oneMonthAgo }
            }
        }
    
        
        private func timeSpentPerDay() -> [(date: Date, totalDuration: Double)] {
            let calendar = Calendar.current
            let filteredLogs = filteredLogs()
            let groupedLogs = Dictionary(grouping: filteredLogs) { log -> Date in
                return calendar.startOfDay(for: log.timestamp ?? Date())
            }
            
            let timePerDay = groupedLogs.map { (date, logsForDay) in
                let totalDuration = logsForDay.reduce(0.0) { $0 + Double($1.duration ?? 0) } / 60.0
                return (date: date, totalDuration: totalDuration)
            }
            
            return timePerDay.sorted { $0.date < $1.date }
        }
        
        private var totalExerciseTime: Double {
            filteredLogs().reduce(0.0) { $0 + Double($1.duration ?? 0) } / 60.0
        }
    
    // Show or hide chart based on available data
    private var showChart: Bool {
        timeSpentPerDay().count > 0
    }

    var body: some View {
        Picker("Time Frame", selection: $selectedTimeFrame) {
            ForEach(TimeFrame.allCases) { timeFrame in
                Text(timeFrame.rawValue).tag(timeFrame)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        if showChart {
            Chart {
                ForEach(timeSpentPerDay(), id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Total Time (min)", item.totalDuration)  // Use Double here
                    )
                }
            }
//            .chartXAxisLabel("Date")
//            .chartYAxisLabel("Total Duration (Minutes)")
            .frame(height: 300)
        }

        Text("Total Time: ") +
        Text("\(formatTotalExerciseTime(totalExerciseTime))")
            .foregroundStyle(colorScheme.current.secondaryText)
        Text("Total Sets Completed: ") +
        Text("\(filteredLogs().count)")
            .foregroundStyle(colorScheme.current.secondaryText)
    }

    private func formatTotalExerciseTime(_ totalMinutes: Double) -> String {
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60

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
