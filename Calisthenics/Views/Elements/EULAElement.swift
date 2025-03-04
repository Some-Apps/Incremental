import SwiftUI

struct EULAElement: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("End User License Agreement (EULA) for Incremental: Calisthenics")
                    .font(.title)
                    .bold()
                
                Text("Last updated: September 2, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Group {
                    Text("1. License")
                        .font(.headline)
                    Text("This End User License Agreement (\"EULA\") is a legal agreement between you (\"User\") and Jared Jones (\"Licensor\") for the use of the Incremental: Calisthenics application (the \"App\"). By downloading, installing, or using the App, you agree to be bound by the terms of this EULA.")
                    
                    Text("2. Grant of License")
                        .font(.headline)
                    Text("Subject to the terms and conditions of this EULA, Licensor grants you a non-exclusive, non-transferable, limited license to use the App on a device that you own or control.")
                    
                    Text("3. Restrictions")
                        .font(.headline)
                    Text("You may not:")
                    Text("• Copy, modify, or create derivative works of the App.")
                    Text("• Reverse engineer, decompile, or disassemble the App.")
                    Text("• Rent, lease, or sublicense the App.")
                    Text("• Use the App in any manner that violates applicable laws or regulations.")
                    
                    Text("4. Ownership")
                        .font(.headline)
                    Text("The App is licensed, not sold. Licensor retains all rights, title, and interest in and to the App, including all intellectual property rights therein. You acknowledge that no ownership rights are transferred to you under this EULA.")
                    
                    Text("5. Termination")
                        .font(.headline)
                    Text("This license is effective until terminated. Your rights under this EULA will terminate automatically without notice if you fail to comply with any of its terms. Upon termination, you must cease all use of the App and delete all copies of the App from your devices.")
                    
                    Text("6. Disclaimer of Warranties")
                        .font(.headline)
                    Text("The App is provided \"as is\" and \"as available\" without warranties of any kind, either express or implied, including, but not limited to, implied warranties of merchantability, fitness for a particular purpose, and non-infringement.")
                    
                    Text("7. Limitation of Liability")
                        .font(.headline)
                    Text("To the fullest extent permitted by law, Licensor shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to your use or inability to use the App, even if advised of the possibility of such damages.")
                    
                    Text("8. Governing Law")
                        .font(.headline)
                    Text("This EULA shall be governed by and construed in accordance with the laws of the State of Wisconsin, without regard to its conflict of law principles.")
                    
                    Text("9. Changes to this EULA")
                        .font(.headline)
                    Text("Licensor may update this EULA from time to time. The updated EULA will be posted within the App and will take effect immediately upon posting. Your continued use of the App following any changes indicates your acceptance of the new EULA.")
                    
                    Text("10. Contact Information")
                        .font(.headline)
                    Text("If you have any questions about this EULA, please contact Jared Jones at: jonesjar222@gmail.com.")
                }
            }
            .padding()
        }
        .navigationTitle("End User License Agreement")
    }
}

#Preview {
    EULAElement()
}
