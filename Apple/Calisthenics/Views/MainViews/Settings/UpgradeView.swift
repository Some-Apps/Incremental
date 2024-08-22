import SwiftUI
import StoreKit

struct UpgradeView: View {
    var body: some View {
        VStack(alignment: .center) {
            
            SubscriptionStoreView(productIDs: ["incrementalProMonthly", "incrementalProYearly", "incrementalProLifetime"]) {
                VStack {
                    Text("Incremental Pro")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .padding()
                    Text("Get access to additional features like exercise stats, graphs, exercise history and support future development.")
                        .multilineTextAlignment(.center)
                }
                .padding()
                .foregroundStyle(.white)
                .containerBackground(.blue.gradient, for: .subscriptionStore)
            }
            .storeButton(.visible, for: .restorePurchases, .redeemCode)
            .subscriptionStoreControlStyle(.prominentPicker)
        }
    }
}

#Preview {
    UpgradeView()
}
