import SafariServices
import SwiftUI
import StoreKit

struct UpgradeView: View {
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        VStack(alignment: .center) {
            
            SubscriptionStoreView(productIDs: ["incrementalProMonthly", "incrementalProYearly"]) {
                VStack {
                    Spacer()
                    Text("Incremental Pro")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .padding()
                    Text("Get access to additional features like exercise stats, graphs, exercise history and support future development.")
                        .multilineTextAlignment(.center)
                        Spacer()
                    HStack {
                        Text("Terms of Service")
                            .underline()
                            .opacity(0.7)
                            .onTapGesture {
                                showTerms = true
                            }

                        Text(" and ")
                            .foregroundStyle(.opacity(0.5))
                        Text("Privacy Policy")
                            .underline()
                            .opacity(0.7)
                            .onTapGesture {
                                showPrivacy = true
                            }
                    }
                    .font(.subheadline)
                }
                .padding()
                .foregroundStyle(.white)
                .containerBackground(.blue.gradient, for: .subscriptionStore)
            }
            .storeButton(.visible, for: .restorePurchases)
            .subscriptionStoreControlStyle(.prominentPicker)
            .sheet(isPresented: $showTerms) {
                SafariView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            }
            .sheet(isPresented: $showPrivacy) {
                SafariView(url: URL(string: "https://jareddanieljones.me/incremental")!)
            }
        }
    }
}

#Preview {
    UpgradeView()
}

// A UIViewControllerRepresentable to wrap SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // No updates required
    }
}
