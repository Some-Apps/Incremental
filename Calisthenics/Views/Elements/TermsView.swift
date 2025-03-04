//
//  TermsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 9/3/24.
//

import SwiftUI

struct TermsView: View {
    @AppStorage("hasAgreedToTerms") var hasAgreedToTerms: Bool = false
        
        var body: some View {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Welcome to Incremental: Calisthenics")
                                .font(.title)
                                .bold()
                            
                            Text("Please review and agree to the following terms to use the app.")
                                .padding(.bottom)
                            
                            NavigationLink(destination: TermsAndConditionsElement()) {
                                Text("View Terms and Conditions")
                                    .font(.headline)
                            }
                            .padding(.bottom)
                            
                            NavigationLink(destination: EULAElement()) {
                                Text("View End User License Agreement (EULA)")
                                    .font(.headline)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            // Handle the case where user disagrees
                            // For example, you might show a dialog explaining why they need to agree
                        }) {
                            Text("Disagree")
                                .foregroundColor(.red)
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            // Set the flag that the user has agreed to the terms
                            hasAgreedToTerms = true
                        }) {
                            Text("Agree")
                                .bold()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationTitle("User Agreement")
            }
        }
}

#Preview {
    TermsView()
}
