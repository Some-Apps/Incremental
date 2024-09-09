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
    @ObservedObject private var defaultsManager = DefaultsManager()
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false

    @Environment(\.dismiss) var dismiss
    
    @State private var notes = ""
    @State private var showUpgrade = false

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
    
    func formattedChangeText(percentage: Double, change: Int) -> Text {
        let color: Color = percentage >= 0 ? colorScheme.current.successButton : colorScheme.current.failButton
        let formattedText = Text("\(percentage, specifier: "%.2f")%") + Text(" (\(change))")
        return formattedText.foregroundColor(color)
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
                Section {
                    if isSubscribed {
                        Chart(sortedLogs, id: \.self) { log in
                            LineMark(x: .value("Date", log.timestamp!), y: .value("Reps", log.reps!))
                                .interpolationMethod(.linear)
                                .foregroundStyle(colorScheme.current.accentText)
                        }
                        .frame(height: 200)
                    } else {
                        Chart(examplePoints, id: \.self) { log in
                            LineMark(x: .value("Date", log.timestamp), y: .value("Reps", log.reps))
                                .interpolationMethod(.linear)
                                .foregroundStyle(colorScheme.current.accentText)

                        }
                        .frame(height: 200)
                        .blur(radius: 5)
                        .overlay {
                            Button("Upgrade") {
                                showUpgrade = true
                            }
                            .buttonStyle(.bordered)
                            .opacity(1)
                        }
                    }
                }
                .listRowBackground(colorScheme.current.secondaryBackground)

                Section {
                    Toggle("Active", isOn: $isActive)
                        .onAppear {
                            isActive = exercise.isActive!
                        }
                        .disabled(randomExercise == exercise.id?.uuidString)
                        .tint(colorScheme.current.successButton)
                    if exercise.units == "Reps" {
                        Text("Current Reps: \(exercise.currentReps ?? 0, specifier: "%.2f")")
                        Text("Last Increment: \(exercise.increment ?? 0, specifier: "%.2f")")
                    } else {
                        let currentDuration = exercise.currentReps ?? 0
                        let lastIncrement = exercise.increment ?? 0

                        let currentMinutes = Int(currentDuration) / 60
                        let currentSeconds = currentDuration.truncatingRemainder(dividingBy: 60)

                        let lastIncrementMinutes = Int(lastIncrement) / 60
                        let lastIncrementSeconds = lastIncrement.truncatingRemainder(dividingBy: 60)

                        Text("Current Duration: \(String(format: "%d:%05.2f", currentMinutes, currentSeconds))")
                        Text("Last Increment: \(String(format: "%.2f", lastIncrement)) seconds")

                    }

                }
                .listRowBackground(colorScheme.current.secondaryBackground)

                Section("Notes") {
                    HStack {
                        Text(notes)
                        Spacer()
                        VStack {
                            Button(action: {
                                isTextEditorSheetPresented.toggle()
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundStyle(colorScheme.current.accentText)
                            }
                            .padding(.top)
                            .sheet(isPresented: $isTextEditorSheetPresented) {
                                NotesEditorView(notes: $notes)
                            }
                            Spacer()
                        }
                    }
                }
                .listRowBackground(colorScheme.current.secondaryBackground)

                Section("Stats") {
                    if isSubscribed {
                        if exercise.units == "Reps" {
                            Text("Total Reps: \(totalReps)")
                            if let averageTimePerRep = averageTimePerRep {
                                Text("Average Time Per Rep: \(averageTimePerRep, specifier: "%.2f") seconds")
                            }
                        } else {
                            Text("Total Duration: \(totalDuration / 60, specifier: "%.2f") minutes")
                        }
                        
                        if let allTimeChange = allTimeChange {
                            Text("All Time Change: ").foregroundColor(colorScheme.current.primaryText) + formattedChangeText(percentage: allTimeChange.percentage, change: allTimeChange.change)
                        }
                        
                        if let oneMonthChange = oneMonthChange {
                            Text("Month: ").foregroundColor(colorScheme.current.primaryText) + formattedChangeText(percentage: oneMonthChange.percentage, change: oneMonthChange.change)
                        } else if let daysUntilAvailable = daysUntilDataAvailable(for: -30 * 24 * 60 * 60) {
                            Text("Month: Available in \(daysUntilAvailable) days")
                        }
                        
                        if let oneYearChange = oneYearChange {
                            Text("Year: ").foregroundColor(colorScheme.current.primaryText) + formattedChangeText(percentage: oneYearChange.percentage, change: oneYearChange.change)
                        } else if let daysUntilAvailable = daysUntilDataAvailable(for: -365 * 24 * 60 * 60) {
                            Text("Year: Available in \(daysUntilAvailable) days")
                        }
                    } else {
                        if exercise.units == "Reps" {
                            
                            HStack {
                                Text("Total Reps: ")
                                Text("\(totalReps)")
                                    .blur(radius: 5)
                                Spacer()
                                Button("Upgrade") {
                                    showUpgrade = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            
                            if let averageTimePerRep = averageTimePerRep {
                                HStack {
                                    Text("Average Time Per Rep: ")
                                    Text("\(averageTimePerRep, specifier: "%.2f") seconds")
                                        .blur(radius: 5)
                                    Spacer()
                                    Button("Upgrade") {
                                        showUpgrade = true
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                            }
                        } else {
                            HStack {
                                Text("Total Duration: ")
                                Text("\(totalDuration / 60, specifier: "%.2f") minutes")
                                    .blur(radius: 5)

                                Spacer()
                                Button("Upgrade") {
                                    showUpgrade = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                        }
                        
                        
                        if let allTimeChange = allTimeChange {
                            HStack {
                                Text("All Time Change: ")
                                Text("\(formattedChangeText(percentage: allTimeChange.percentage, change: allTimeChange.change))")
                                    .blur(radius: 5)

                                Spacer()
                                Button("Upgrade") {
                                    showUpgrade = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                        }
                        
                        if let oneMonthChange = oneMonthChange {

                            HStack {
                                Text("Month Change: ")
                                Text("\(formattedChangeText(percentage: oneMonthChange.percentage, change: oneMonthChange.change))")
                                    .blur(radius: 5)

                                Spacer()
                                Button("Upgrade") {
                                    showUpgrade = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                        } else if let daysUntilAvailable = daysUntilDataAvailable(for: -30 * 24 * 60 * 60) {
                            Text("Month Change: Available in \(daysUntilAvailable) days")
                        }
                        
                        if let oneYearChange = oneYearChange {
                            HStack {
                                Text("Year Change: ")
                                Text("\(formattedChangeText(percentage: oneYearChange.percentage, change: oneYearChange.change))")
                                    .blur(radius: 5)

                                Spacer()
                                Button("Upgrade") {
                                    showUpgrade = true
                                }
                                .buttonStyle(.bordered)
                            }                       
                        } else if let daysUntilAvailable = daysUntilDataAvailable(for: -365 * 24 * 60 * 60) {
                                Text("Year Change: Available in \(daysUntilAvailable) days")
                            }
                    }
                    
                    
                    
                }
                .listRowBackground(colorScheme.current.secondaryBackground)

            }
            .listStyle(.automatic)
            
        }
        .scrollContentBackground(.hidden)
        .background(colorScheme.current.primaryBackground)
        .foregroundStyle(colorScheme.current.primaryText, colorScheme.current.secondaryText)
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
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
                .foregroundStyle((isActive == exercise.isActive && notes == exercise.notes) ? colorScheme.current.accentText.opacity(0.5) : colorScheme.current.accentText)
            }
        }
        .onAppear {
            Task {
                try await fetchPurchases()
            }
        }
        .accentColor(colorScheme.current.accentText) // <- note that it's added here and not on the List like navigationBarTitle()
    }
    
    func fetchPurchases() async throws {
        for await entitlement in Transaction.currentEntitlements {
            do {
                let verifiedPurchase = try verifyPurchase(entitlement)
                
                switch verifiedPurchase.productType {
                case .nonConsumable:
                    isSubscribed = true
                case .autoRenewable:
                    isSubscribed = true
                default:
                    break
                }
            } catch {
                throw error
            }
        }
    }
    private func verifyPurchase<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw MyError.runtimeError("error")
        case .verified(let safe):
            return safe
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
