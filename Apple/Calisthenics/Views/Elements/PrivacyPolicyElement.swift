import SwiftUI


struct PrivacyPolicyElement: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy for Incremental: Calisthenics")
                    .font(.title)
                    .bold()
                
                Text("Last updated: September 2, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("This Privacy Policy describes the practices regarding the personal information associated with the use of the Incremental: Calisthenics application (the \"App\").")
                
                Section(header: Text("Information We Collect").font(.headline)) {
                    Text("We respect your privacy. When you use the App, we do not collect or store any of your personal information. We do not require users to provide any personal information such as name, email address, or other identifiers.")
                    
                    Text("The App does not automatically collect any data related to your device, including information about your web browser, IP address, time zone, or any cookies that are installed on your device.")
                }
                
                Section(header: Text("Subscriptions and Payments").font(.headline)) {
                    Text("The App offers monthly and yearly subscriptions to Incremental Pro, which provide additional features such as advanced stats, graphs, exercise history, and the ability to export all data. Payments for these subscriptions are handled through the App Store, and we do not collect or store any payment information.")
                    
                    Text("All transactions are processed through the App Store, and we adhere to the privacy policies and terms of service provided by the App Store. We do not have access to your payment information, and any queries or issues related to payments should be directed to the App Store support.")
                }
                
                Section(header: Text("How We Use Your Information").font(.headline)) {
                    Text("Since we do not collect any personal information, there's no data usage related to individual users. The App is designed to function without storing or processing personal data.")
                }
                
                Section(header: Text("Sharing Your Information").font(.headline)) {
                    Text("We do not and cannot share your personal information, as we do not collect any.")
                }
                
                Section(header: Text("Security").font(.headline)) {
                    Text("Given that no personal data is collected, your privacy is inherently protected. However, we recommend always ensuring that your device's operating system and all apps are updated to the latest versions to maximize your digital security.")
                }
                
                Section(header: Text("Changes to this Policy").font(.headline)) {
                    Text("We may update our Privacy Policy from time to time. Any changes will be reflected by the revision date at the top of the policy. Since we do not collect personal data, these updates are typically related to clarity or legal precision.")
                }
                
                Section(header: Text("Contact Us").font(.headline)) {
                    Text("If you have any questions about this Privacy Policy, please contact Jared Jones at: jonesjar222@gmail.com")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}


#Preview {
    PrivacyPolicyElement()
}
