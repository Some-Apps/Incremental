import SwiftUI
import StoreKit
import AlertToast
import SwiftData
import CloudKit

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Exercise> { item in
        true
    }, sort: \.title) var exercises: [Exercise]
    @Query(filter: #Predicate<Log> { item in
        true
    }, sort: \.timestamp) var logs: [Log]
    @State private var showUpgrade = false
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false
    @State private var showLoading = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @AppStorage("healthActivityCategory") var healthActivityCategory: String = "Functional Strength Training"
    
    // New state variables for delete confirmation
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage: String = ""
    
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
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
        // Alert for delete confirmation
        .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete all your data? This action cannot be undone.")
        }
        // Toasts for success and error
        .toast(isPresenting: $showDeleteSuccess) {
            AlertToast(type: .complete(Color.green), title: "All data deleted successfully.")
        }
        .toast(isPresenting: $showDeleteError) {
            AlertToast(type: .error(Color.red), title: deleteErrorMessage)
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
//                if false {

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
            
            Section {
                // Updated Delete All Data Button
                Button("Delete All Data") {
                    showDeleteConfirmation = true
                }
                .foregroundColor(.red) // Highlight the delete button
            }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .onDisappear {
                    Task {
                        do {
                            try await fetchPurchases()
                        } catch {
                            print("Error fetching purchases: \(error)")
                        }
                    }
                }
        }
        .toast(isPresenting: $showLoading) {
            AlertToast(displayMode: .alert, type: .loading, title: "Loading...")
        }
        .onAppear {
            Task {
                do {
                    try await fetchPurchases()
                } catch {
                    print("Error fetching purchases: \(error)")
                }
            }
        }
    }
    
    // MARK: - Delete All Data Function
    func deleteAllData() {
        showLoading = true
        
        Task {
            do {
                // Delete all Exercise objects from SwiftData
                for exercise in exercises {
                    modelContext.delete(exercise)
                }
                for log in logs {
                    modelContext.delete(log)
                }
                try modelContext.save()
                
                // Optionally, delete from CloudKit if you're managing it separately
                // Assuming you're using a custom CloudKit setup
                // Uncomment and modify the following lines based on your CloudKit schema
                /*
                let container = CKContainer.default()
                let privateDatabase = container.privateCloudDatabase
                let fetchOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [/* Your Zone IDs */])
                
                // Implement the necessary CloudKit deletion logic here
                */
                
                // If using NSPersistentCloudKitContainer, deletion from modelContext should sync with CloudKit automatically
                
                DispatchQueue.main.async {
                    showLoading = false
                    showDeleteSuccess = true
                }
            } catch {
                print("Error deleting data: \(error)")
                DispatchQueue.main.async {
                    showLoading = false
                    deleteErrorMessage = "Failed to delete data: \(error.localizedDescription)"
                    showDeleteError = true
                }
            }
        }
    }
    
    // Existing functions...

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
