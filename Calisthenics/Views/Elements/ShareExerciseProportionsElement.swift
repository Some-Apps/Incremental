import SwiftUI
import UIKit

struct ExerciseProportionsView: View {
    @Environment(\.colorScheme) var colorScheme
    var exercises: [Exercise]
    @State private var isShareSheetPresented = false
    @State private var shareImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 5) {
                        // Inline title and share button
                        HStack {
                            Text("Exercise Proportions")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                            Button(action: {
                                // Show loading toast and delay share sheet presentation
                                self.isLoading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.shareImage = generateShareImage()
                                    self.isLoading = false
                                    self.isShareSheetPresented = true
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        .padding()

                        ForEach(exercises, id: \.self) { exercise in
                            HStack {
                                Text(exercise.title ?? "Unknown")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(exercise.logs?.last?.reps ?? 0)) reps")
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                
                // Loading overlay toast
                if isLoading {
                    VStack {
                        Spacer()
                        Text("Loading...")
                            .padding()
                            .cornerRadius(10)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
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
        // Calculate dynamic image height based on exercises count
        let lineHeight: CGFloat = 25
        let baseHeight: CGFloat = 130
        let bottomPadding: CGFloat = 20
        let exerciseCount = CGFloat(exercises.count)
        let calculatedHeight = baseHeight + (lineHeight + 5) * exerciseCount + bottomPadding
        let finalHeight = max(800, calculatedHeight)
        
        let imageSize = CGSize(width: 400, height: finalHeight)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            // Fill background with white or black
            if colorScheme == .dark {
                UIColor.black.setFill()
            } else {
                UIColor.white.setFill()
            }
            context.fill(CGRect(origin: .zero, size: imageSize))
            
            // Draw App Logo as a rounded icon if available
            if let appLogo = UIImage(named: "icon") {
                let logoSize = CGSize(width: 60, height: 60)
                let logoRect = CGRect(x: 20, y: 20, width: logoSize.width, height: logoSize.height)
                let path = UIBezierPath(ovalIn: logoRect)
                context.cgContext.addPath(path.cgPath)
                context.cgContext.clip()
                appLogo.draw(in: logoRect)
                context.cgContext.resetClip()
            }
            
            // Draw App Name centered vertically with the logo
            let appName = "Incremental: Calisthenics"
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: colorScheme == .dark ? UIColor.white : UIColor.black
            ]
            let textSize = (appName as NSString).size(withAttributes: appNameAttributes)
            let appNameX: CGFloat = 20 + 60 + 10
            let appNameY: CGFloat = 20 + (60 - textSize.height) / 2
            let appNameRect = CGRect(x: appNameX, y: appNameY, width: imageSize.width - appNameX - 20, height: textSize.height)
            appName.draw(in: appNameRect, withAttributes: appNameAttributes)
            
            // Draw header
            let header = "Exercise Proportions"
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: colorScheme == .dark ? UIColor.white : UIColor.black
            ]
            let headerRect = CGRect(x: 20, y: 90, width: imageSize.width - 40, height: 30)
            header.draw(in: headerRect, withAttributes: headerAttributes)
            
            // Draw each exercise detail
            var currentY: CGFloat = baseHeight
            for exercise in exercises {
                let exerciseTitle = exercise.title ?? "Unknown"
                let reps = Int(exercise.logs?.last?.reps ?? 0)
                let exerciseText = "\(exerciseTitle): \(reps) reps"
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: colorScheme == .dark ? UIColor.white : UIColor.black
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
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
