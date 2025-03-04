import SwiftUI

struct TermsAndConditionsElement: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms and Conditions for Incremental: Calisthenics")
                    .font(.title)
                    .bold()
                
                Text("Last updated: September 2, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Group {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By downloading, installing, or using the Incremental: Calisthenics application (the \"App\"), you agree to be bound by these Terms and Conditions (\"Terms\"). If you do not agree to these Terms, please do not use the App.")
                    
                    Text("2. Use of the App")
                        .font(.headline)
                    Text("• **Eligibility:** You must be at least 13 years old to use the App. By using the App, you represent and warrant that you meet this eligibility requirement.")
                    Text("• **License:** We grant you a non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes.")
                    Text("• **Prohibited Activities:** You agree not to use the App for any illegal activities or in a manner that violates these Terms, including but not limited to:")
                    Text("  - Reverse engineering, decompiling, or disassembling the App.")
                    Text("  - Using the App to infringe upon the intellectual property rights of others.")
                    Text("  - Attempting to gain unauthorized access to the App or its related systems or networks.")
                }
                
                Group {
                    Text("3. Subscriptions and Payments")
                        .font(.headline)
                    Text("• **Incremental Pro:** The App offers monthly and yearly subscriptions to Incremental Pro, which provide additional features. Subscriptions are billed through your App Store account.")
                    Text("• **Payment Terms:** All payments are handled through the App Store. You agree to the payment terms provided by the App Store. We do not have access to or store your payment information.")
                    Text("• **Cancellation:** You may cancel your subscription at any time through your App Store account settings. No refunds will be provided for unused portions of a subscription period.")
                    
                    Text("4. Intellectual Property")
                        .font(.headline)
                    Text("• **Ownership:** All intellectual property rights in the App, including but not limited to content, graphics, and software, are owned by Jared Jones or its licensors.")
                    Text("• **License Restrictions:** You may not copy, modify, distribute, sell, or lease any part of the App without our prior written consent.")
                    
                    Text("5. Limitation of Liability")
                        .font(.headline)
                    Text("• **Disclaimer:** The App is provided \"as is\" and \"as available\" without warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted or error-free.")
                    Text("• **Limitation:** To the fullest extent permitted by law, Jared Jones will not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to your use of the App.")
                    
                    Text("6. Termination")
                        .font(.headline)
                    Text("We reserve the right to terminate or suspend your access to the App at any time, without notice, for conduct that we believe violates these Terms or is harmful to other users of the App, us, or third parties, or for any other reason.")
                    
                    Text("7. Governing Law")
                        .font(.headline)
                    Text("These Terms are governed by and construed in accordance with the laws of the State of Wisconsin, without regard to its conflict of law principles.")
                    
                    Text("8. Changes to These Terms")
                        .font(.headline)
                    Text("We may update these Terms from time to time. The updated Terms will be posted within the App and will take effect immediately upon posting. Your continued use of the App following any changes indicates your acceptance of the new Terms.")
                    
                    Text("9. Contact Us")
                        .font(.headline)
                    Text("If you have any questions about these Terms, please contact Jared Jones at: jonesjar222@gmail.com.")
                }
            }
            .padding()
        }
        .navigationTitle("Terms and Conditions")
    }
}


#Preview {
    TermsAndConditionsElement()
}
