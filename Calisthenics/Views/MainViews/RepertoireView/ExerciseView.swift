import Charts
import SwiftUI
import SwiftData
import StoreKit

struct ExamplePoint: Identifiable, Hashable {
    let id = UUID()
    let reps: Int
    let timestamp: Date
}

struct ExerciseView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState
    
    @AppStorage("randomExercise") var randomExercise: String = ""
    @State private var isTextEditorSheetPresented = false
    @State private var showDeleteAlert = false
    @ObservedObject private var defaultsManager = DefaultsManager()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var notes = ""
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currentTab") var currentTab: Int = 0
    
    let exercise: Exercise
    
    var sortedLogs: [Log] {
        let logsArray = exercise.logs
        return logsArray!.sorted { $0.timestamp! < $1.timestamp! }
    }
    
    @State private var isActive = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._notes = State(initialValue: exercise.notes!)
    }
    
    var totalReps: Int {
        sortedLogs.reduce(0) { $0 + Int($1.reps!) }
    }
    
    var totalDuration: TimeInterval {
        sortedLogs.reduce(0) { $0 + TimeInterval($1.duration!) }
    }
    
    var averageTimePerRep: TimeInterval? {
        guard totalReps > 0 else { return nil }
        return totalDuration / Double(totalReps)
    }
    
    var oneMonthChange: (percentage: Double, change: Int)? {
        calculateChange(timeInterval: -30 * 24 * 60 * 60)
    }
    
    var oneYearChange: (percentage: Double, change: Int)? {
        calculateChange(timeInterval: -365 * 24 * 60 * 60)
    }
    
    var allTimeChange: (percentage: Double, change: Int)? {
        guard let firstLog = sortedLogs.first, let currentReps = exercise.currentReps else { return nil }
        let change = Int(currentReps) - Int(firstLog.reps!)
        let percentage = (Double(change) / Double(firstLog.reps!)) * 100
        return (percentage, change)
    }
    
    func calculateChange(timeInterval: TimeInterval) -> (percentage: Double, change: Int)? {
        let now = Date()
        guard let currentReps = exercise.currentReps else { return nil }
        
        let targetDate = now.addingTimeInterval(timeInterval)
        let targetLog = sortedLogs.last { $0.timestamp! <= targetDate }
        
        guard let previousReps = targetLog?.reps else { return nil }
        
        let change = Int(currentReps) - Int(previousReps)
        let percentage = (Double(change) / Double(previousReps)) * 100
        return (percentage, change)
    }
    
    func daysUntilDataAvailable(for timeInterval: TimeInterval) -> Int? {
        let now = Date()
        let targetDate = now.addingTimeInterval(timeInterval)
        guard let firstLogDate = sortedLogs.first?.timestamp else { return nil }
        
        if firstLogDate > targetDate {
            return Calendar.current.dateComponents([.day], from: targetDate, to: firstLogDate).day
        } else {
            return nil
        }
    }
    
    func formattedChangeText(percentage: Double, change: Int) -> Text? {
        let roundedPercentage = round(percentage)
        guard roundedPercentage != 0 else { return nil }
        let color: Color = roundedPercentage >= 0 ? .green : .red
        let formattedPercentage = String(format: "%.0f%%", abs(roundedPercentage)) + " (\(abs(change)))"
        return Text(formattedPercentage).foregroundColor(color)
    }
    
    let examplePoints: [ExamplePoint] = [
        ExamplePoint(reps: 10, timestamp: Date()),
        ExamplePoint(reps: 12, timestamp: Date().addingTimeInterval(86400)),
        ExamplePoint(reps: 15, timestamp: Date().addingTimeInterval(172800)),
        ExamplePoint(reps: 14, timestamp: Date().addingTimeInterval(259200)),
        ExamplePoint(reps: 18, timestamp: Date().addingTimeInterval(345600)),
        ExamplePoint(reps: 20, timestamp: Date().addingTimeInterval(432000)),
        ExamplePoint(reps: 17, timestamp: Date().addingTimeInterval(518400)),
        ExamplePoint(reps: 22, timestamp: Date().addingTimeInterval(604800)),
        ExamplePoint(reps: 25, timestamp: Date().addingTimeInterval(691200)),
        ExamplePoint(reps: 23, timestamp: Date().addingTimeInterval(777600)),
        ExamplePoint(reps: 27, timestamp: Date().addingTimeInterval(864000)),
        ExamplePoint(reps: 30, timestamp: Date().addingTimeInterval(950400)),
        ExamplePoint(reps: 28, timestamp: Date().addingTimeInterval(1036800)),
        ExamplePoint(reps: 32, timestamp: Date().addingTimeInterval(1123200)),
        ExamplePoint(reps: 35, timestamp: Date().addingTimeInterval(1209600)),
        ExamplePoint(reps: 33, timestamp: Date().addingTimeInterval(1296000)),
        ExamplePoint(reps: 38, timestamp: Date().addingTimeInterval(1382400)),
        ExamplePoint(reps: 40, timestamp: Date().addingTimeInterval(1468800)),
        ExamplePoint(reps: 37, timestamp: Date().addingTimeInterval(1555200)),
        ExamplePoint(reps: 42, timestamp: Date().addingTimeInterval(1641600))
    ]
    
    var body: some View {
        VStack {
            Text(exercise.title!)
            List {
                if sortedLogs.count > 1
                {
                    Section {
                        Chart(sortedLogs, id: \.self) { log in
                            LineMark(x: .value("Date", log.timestamp!), y: .value("Reps", log.reps!))
                                .interpolationMethod(.linear)
                        }
                        .frame(height: 200)
                        
                    }
                    .listRowBackground(colorScheme.current.secondaryBackground)
                }
                
                Section {
                    Toggle("Active", isOn: $isActive)
                        .onAppear {
                            isActive = exercise.isActive!
                        }
                        .disabled(randomExercise == exercise.id?.uuidString)
                        .tint(.green)
                    if exercise.units == "Reps" {
                        HStack {
                            Text("Current Reps:")
                            Spacer()
                            Text("\(exercise.currentReps ?? 0, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Last Increment:")
                            Spacer()
                            Text("\(exercise.increment ?? 0, specifier: "%.2f")")
                        }
                    } else {
                        let currentDuration = exercise.currentReps ?? 0
                        let lastIncrement = exercise.increment ?? 0
                        let currentMinutes = Int(currentDuration) / 60
                        let currentSeconds = currentDuration.truncatingRemainder(dividingBy: 60)
                        HStack {
                            Text("Current Duration:")
                            Spacer()
                            Text("\(String(format: "%d:%05.2f", currentMinutes, currentSeconds))")
                        }
                        HStack {
                            Text("Last Increment:")
                            Spacer()
                            Text("\(String(format: "%.2f", lastIncrement)) seconds")
                        }
                    }
                    
                } header: {
                    Text("Status")
                        .foregroundStyle(colorScheme.current.secondaryText)
                }
                .listRowBackground(colorScheme.current.secondaryBackground)
                
                Section {
                    HStack {
                        Text(notes)
                        Spacer()
                        VStack {
                            Button(action: {
                                isTextEditorSheetPresented.toggle()
                            }) {
                                Image(systemName: "pencil")
                            }
                            .padding(.top)
                            .sheet(isPresented: $isTextEditorSheetPresented) {
                                NotesEditorView(notes: $notes)
                            }
                            Spacer()
                        }
                    }
                } header: {
                    Text("Notes")
                        .foregroundStyle(colorScheme.current.secondaryText)
                }
                .listRowBackground(colorScheme.current.secondaryBackground)
                
                Section {
                    if exercise.units == "Reps" {
                        HStack {
                            Text("Total Reps:")
                            Spacer()
                            Text("\(totalReps)")
                        }
                        if let averageTimePerRep = averageTimePerRep {
                            HStack {
                                Text("Average Time Per Rep:")
                                Spacer()
                                Text("\(averageTimePerRep, specifier: "%.2f") seconds")
                            }
                        }
                    } else {
                        HStack {
                            Text("Total Duration:")
                            Spacer()
                            Text("\(totalDuration / 60, specifier: "%.2f") minutes")
                        }
                    }
                    // Total Sets
                    HStack {
                        Text("Total Sets:")
                        Spacer()
                        Text(sortedLogs.count.description)
                    }
                    
                    // All Time Change
                    if let allTimeChange = allTimeChange, let formattedText = formattedChangeText(percentage: allTimeChange.percentage, change: allTimeChange.change) {
                        HStack {
                            Text("All Time Change:")
                            Spacer()
                            formattedText
                        }
                    }
                    
                    // One Month Change
                    if let oneMonthChange = oneMonthChange, let formattedText = formattedChangeText(percentage: oneMonthChange.percentage, change: oneMonthChange.change) {
                        HStack {
                            Text("Month:")
                            Spacer()
                            formattedText
                        }
                    } else if let daysUntilAvailable = daysUntilDataAvailable(for: -30 * 24 * 60 * 60) {
                        HStack {
                            Text("Month:")
                            Spacer()
                            Text("Available in \(daysUntilAvailable) days")
                        }
                    }
                    
                    // One Year Change
                    if let oneYearChange = oneYearChange, let formattedText = formattedChangeText(percentage: oneYearChange.percentage, change: oneYearChange.change) {
                        HStack {
                            Text("Year:")
                            Spacer()
                            formattedText
                        }
                    } else if let daysUntilAvailable = daysUntilDataAvailable(for: -365 * 24 * 60 * 60) {
                        HStack {
                            Text("Year:")
                            Spacer()
                            Text("Available in \(daysUntilAvailable) days")
                        }
                    }
                    
                } header: {
                    Text("Stats")
                        .foregroundStyle(colorScheme.current.secondaryText)
                    
                }
                .listRowBackground(colorScheme.current.secondaryBackground)
                
                Button("Delete Exercise") {
                    showDeleteAlert = true
                }
                .foregroundStyle(.red)
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme.current.primaryBackground)
            .foregroundStyle(colorScheme.current.primaryText, colorScheme.current.secondaryText)
            .onDisappear() {
                dismiss()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        exercise.notes = notes
                        exercise.isActive = isActive
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(isActive == exercise.isActive && notes == exercise.notes)
                }
            }
        }
        .alert("Delete Exercise", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(exercise)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this exercise? This action cannot be undone.")
        }
    }
    
    enum MyError: Error {
        case runtimeError(String)
    }
}

struct NotesEditorView: View {
    enum FocusedField {
        case active, inactive
    }
    
    @Environment(\.dismiss) var dismiss
    @Binding var notes: String
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $notes)
                    .padding()
                    .focused($focusedField, equals: .active)
                    .onAppear {
                        focusedField = .active
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
