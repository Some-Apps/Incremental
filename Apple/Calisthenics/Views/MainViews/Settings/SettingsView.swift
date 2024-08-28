import SwiftUI
import StoreKit
import AlertToast
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Exercise> {item in
        true
    }, sort: \.title) var exercises: [Exercise]

    @State private var showUpgrade = false
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false
    @State private var showLoading = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @AppStorage("healthActivityCategory") var healthActivityCategory: String = "Functional Strength Training"
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    let activityCategories = ["Core Training", "Functional Strength Training", "High-Intensity Interval Training", "Mixed Cardio", "Other", "Traditional Strength Training"]
    
    var body: some View {
        Group {
            if idiom == .pad || idiom == .mac {
                NavigationStack {
                    formContent
                }
            } else {
                NavigationView {
                    formContent
                        .navigationTitle("Settings")
                }
            }
        }
        
        .sheet(isPresented: Binding(
            get: { showShareSheet },
            set: { showShareSheet = $0 }
        )) {
            ActivityView(activityItems: shareItems)
        }
    }
    
    private var formContent: some View {
        Form {
            Section {
                NavigationLink("How To Use App", destination: TutorialView())
                if isSubscribed {
                    NavigationLink("Exercise History", destination: ExerciseHistoryView())
                } else {
                    HStack {
                        Text("Exercise History")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Upgrade") {
                            showUpgrade = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                if isSubscribed {
                    Button("Export All Data") {
                        fetchAllData()
                    }
                } else {
                    HStack {
                        Text("Export All Data")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Upgrade") {
                            showUpgrade = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
            }
            Section {
                Picker("Health Category", selection: $healthActivityCategory) {
                    ForEach(activityCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            Section {
                // Upgrade to Calisthenics Pro
                if isSubscribed {
                    HStack {
                        Text("Incremental Pro")
                        Spacer()
                        Text("Subscribed")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button {
                        showUpgrade.toggle()
                    } label: {
                            Text("Upgrade to Incremental Pro")
                    }
                }
                
            }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
        .toast(isPresenting: $showLoading) {
            AlertToast(displayMode: .alert, type: .loading, title: "Loading...")
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
    
    func fetchAllData() {
        showLoading = true
        
        var csvString = "exercise,log date,log reps\n"
        
        fetchAllExercises(from: exercises) { exercise in
            csvString.append(contentsOf: exercise)
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                saveAndShareCSV(csvString: csvString)
            }
            
        }
        
    }
    
    func fetchAllExercises(from collection: [Exercise], completion: @escaping (String) -> Void) {
        var csvString = ""
        
        for exercise in exercises {
            csvString.append(contentsOf: formatExerciseToCSV(exercise: exercise))
        }
        completion(csvString)
    }
    
    func saveAndShareCSV(csvString: String) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            showLoading = false
            return
        }
        
        let filePath = documentDirectory.appendingPathComponent("incremental.csv")
        
        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            if fileManager.fileExists(atPath: filePath.path) {
                DispatchQueue.main.async {
                    self.showLoading = false
                    self.shareItems = [filePath]
                    self.showShareSheet = true
                }
                print("CSV saved to \(filePath)")
            } else {
                print("File does not exist at path: \(filePath)")
                DispatchQueue.main.async {
                    self.showLoading = false
                }
            }
        } catch {
            print("Failed to create file: \(error)")
            DispatchQueue.main.async {
                self.showLoading = false
            }
        }
    }

    func formatExerciseToCSV(exercise: Exercise) -> String {
        var csvRows = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let logs = exercise.logs else { return "" }
        
        let sortedLogs = logs.sorted { ($0.timestamp ?? Date()) > ($1.timestamp ?? Date()) }

        
        // Include the exercise name in the first row, then leave it blank for subsequent rows
        for (index, log) in sortedLogs.enumerated() {
            let exerciseName = index == 0 ? escapeCSV(exercise.title ?? "") : ""
            
            let row = "\(exerciseName),\(dateFormatter.string(from: log.timestamp ?? Date())),\(log.reps?.description ?? "")"
            csvRows.append(row)
        }
        
        // Add a new line after the last log for each exercise
        csvRows.append("")
        
        return csvRows.joined(separator: "\n")
    }

    
    func escapeCSV(_ field: String) -> String {
        var escapedField = field
        if escapedField.contains("\"") {
            escapedField = escapedField.replacingOccurrences(of: "\"", with: "\"\"")
        }
        if escapedField.contains(",") || escapedField.contains("\n") || escapedField.contains("\"") {
            escapedField = "\"\(escapedField)\""
        }
        return escapedField
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
