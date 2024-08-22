import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var showUpgrade = false
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false

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
//                NavigationLink("Progression Photos", destination: ProgressionPhotosView())
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
                Button {
                    showUpgrade.toggle()
                } label: {
                    if isSubscribed {
                        Text("Incremental Pro")
                    } else {
                        Text("Upgrade to Incremental Pro")
                    }
                }
            }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
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
