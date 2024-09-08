import SwiftUI

struct ColorSchemePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var colorScheme: ColorSchemeState

    let colorSchemes: [(name: String, scheme: MyColorSchemeType)] = [
        ("Main", .main),
        ("Alternative", .alternative)
    ]
    
    var body: some View {
            List(colorSchemes, id: \.name) { scheme in
                Button(action: {
                    colorScheme.updateColorScheme(to: scheme.scheme)
                    presentationMode.wrappedValue.dismiss() // Dismiss the view when a selection is made
                }) {
                    HStack {
                        Text(scheme.name)
                            .foregroundStyle(Color.primaryText)
                        Spacer()
                        ColorPreviewView(colorScheme: scheme.scheme.colorScheme)
                    }
                }
                .listRowBackground(Color.tertiaryBackground)

            }
            .scrollContentBackground(.hidden)
            .background(Color.secondaryBackground)
            .navigationBarTitle("Select Color Scheme", displayMode: .inline)
        
    }
}

struct ColorPreviewView: View {
    let colorScheme: MyColorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(colorScheme.primaryBackground)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.secondaryBackground)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.tertiaryBackground)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.cardBackground)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.accentText)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.primaryText)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.secondaryText)
                .frame(width: 15, height: 30)
            Rectangle()
                .fill(colorScheme.tertiaryText)
                .frame(width: 15, height: 30)
        }
        .border(.black)
    }
}
