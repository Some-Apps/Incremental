import SwiftUI
import UIKit

struct ExerciseProportionsView: View {
    var exercises: [Exercise]
    @State private var isShareSheetPresented = false
    @State private var shareImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 5) {
                        Text("Exercise Proportions")
                            .font(.largeTitle)
                            .bold()
                        
                        ForEach(exercises, id: \.self) { exercise in
                            HStack {
                                Text(exercise.title ?? "Unknown")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(exercise.logs?.last?.reps ?? 0)) reps")
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                }
                .navigationBarItems(trailing: Button(action: {
                    // Show loading toast and delay share sheet presentation
                    self.isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.shareImage = generateShareImage()
                        self.isLoading = false
                        self.isShareSheetPresented = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                })
                
                // Loading overlay toast
                if isLoading {
                    VStack {
                        Spacer()
                        Text("Preparing content...")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
                }
            }
            .sheet(isPresented: $isShareSheetPresented, content: {
                if let shareImage = shareImage {
                    ShareSheet(activityItems: [shareImage])
                }
            })
        }
    }
    
    /// Generates a custom share image containing the app logo, app name, and exercise details.
    func generateShareImage() -> UIImage {
        let imageSize = CGSize(width: 600, height: 800)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            // Fill background with white
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))
            
            // Draw App Logo if available
            if let logo = UIImage(named: "AppIcon") {
                let logoRect = CGRect(x: 20, y: 20, width: 50, height: 50)
                logo.draw(in: logoRect)
            }
            
            // Draw App Name
            let appName = "Incremental Calisthenics"
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let appNameRect = CGRect(x: 80, y: 20, width: imageSize.width - 100, height: 50)
            appName.draw(in: appNameRect, withAttributes: appNameAttributes)
            
            // Draw header
            let header = "Exercise Proportions"
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black
            ]
            let headerRect = CGRect(x: 20, y: 90, width: imageSize.width - 40, height: 30)
            header.draw(in: headerRect, withAttributes: headerAttributes)
            
            // Draw each exercise detail
            var currentY: CGFloat = 130
            let lineHeight: CGFloat = 25
            for exercise in exercises {
                let exerciseTitle = exercise.title ?? "Unknown"
                let reps = Int(exercise.logs?.last?.reps ?? 0)
                let exerciseText = "\(exerciseTitle): \(reps) reps"
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray
                ]
                let textRect = CGRect(x: 20, y: currentY, width: imageSize.width - 40, height: lineHeight)
                exerciseText.draw(in: textRect, withAttributes: textAttributes)
                currentY += lineHeight + 5
            }
        }
        return image
    }
}

/// A SwiftUI wrapper for UIActivityViewController to share content.
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
