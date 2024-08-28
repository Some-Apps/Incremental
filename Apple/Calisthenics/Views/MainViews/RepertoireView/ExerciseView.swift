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
            Form {
                Section {
                    if isSubscribed {
                        Chart(sortedLogs, id: \.self) { log in
                            LineMark(x: .value("Date", log.timestamp!), y: .value("Reps", log.reps!))
                                .interpolationMethod(.catmullRom)
                        }
                        .frame(height: 200)
                    } else {
                        Chart(examplePoints, id: \.self) { log in
                            LineMark(x: .value("Date", log.timestamp), y: .value("Reps", log.reps))
                                .interpolationMethod(.catmullRom)
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
                Section {
                    Toggle("Active", isOn: $isActive)
                        .onAppear {
                            isActive = exercise.isActive!
                        }
                        .disabled(randomExercise == exercise.id?.uuidString)
                    Text("Current Reps: \(exercise.currentReps ?? 0, specifier: "%.2f")")
                    Text("Last Increment: \(exercise.increment ?? 0, specifier: "%.2f")")
                }
                Section("Notes") {
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
                }
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
                    } else {
                        Text("Time Spent: ?")
                        Text("Total Reps: ?")
                        Text("Average Time Per Rep: ?")
                        Text("Record Reps Without Pausing: ?")
                        Text("Exercise Performed Every ? Days")
                    }
                    
                }
//                Section {
//                    Button("Do Exercise") {
//                        randomExercise = exercise.id!.uuidString
//                        defaultsManager.saveDataToiCloud(key: "randomExercise", value: randomExercise)
//                        currentTab = 0
//                    }
//                }
            }
        }
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
            }
        }
        .onAppear {
            Task {
                try await fetchPurchases()
            }
        }
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

