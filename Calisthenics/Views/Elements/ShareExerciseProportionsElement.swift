import SwiftUI
import UIKit
import AlertToast

struct ExerciseProportionsView: View {
    @Environment(\.colorScheme) var colorScheme
    var exercises: [Exercise]
    @State private var isShareSheetPresented = false
    @State private var shareImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(exercises, id: \.self) { exercise in
                    HStack {
                        HStack(spacing: 4) {
                            Text(exercise.title ?? "Unknown")
                            if exercise.leftRight ?? false {
                                Image(systemName: "arrow.left.arrow.right.square")
                                    .opacity(0.5)
                            }
                        }
                        Spacer()
                        if exercise.units == "Reps" {
                            Text("\(Int(exercise.logs?.last?.reps ?? 0)) reps")
                        } else {
                            Text(String(format: "%02d:%02d",
                                        Int(exercise.logs?.last?.reps ?? 0) / 60,
                                        Int(exercise.logs?.last?.reps ?? 0) % 60))
                        }
                    }
                }
            }
            .navigationTitle("Exercise Proportions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.shareImage = generateShareImage()
                    self.isLoading = false
                    self.isShareSheetPresented = true
                }
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            )
            .toast(isPresenting: $isLoading) {
                AlertToast(type: .loading, title: "Loading...")
            }
        }
        .sheet(isPresented: Binding(
            get: { isShareSheetPresented },
            set: { isShareSheetPresented = $0 }
                    )) {
                        ShareSheet(activityItems: [shareImage as Any])
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
                let leftMargin: CGFloat = 20
                let rightMargin: CGFloat = 20
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: colorScheme == .dark ? UIColor.white : UIColor.black
                ]
                
                // Left part: title and optional icon
                let titleText = exercise.title ?? "Unknown"
                let titleSize = (titleText as NSString).size(withAttributes: textAttributes)
                var leftX = leftMargin
                let titleRect = CGRect(x: leftX, y: currentY, width: titleSize.width, height: lineHeight)
                titleText.draw(in: titleRect, withAttributes: textAttributes)
                leftX += titleSize.width
                
                if exercise.leftRight ?? false {
                    let iconSpacing: CGFloat = 4
                    leftX += iconSpacing
                    if let originalIconImage = UIImage(systemName: "arrow.left.arrow.right.square") {
                        let tintColor = colorScheme == .dark ? UIColor.gray : UIColor.gray
                        let iconImage = originalIconImage.withTintColor(tintColor, renderingMode: .alwaysOriginal)
                        let iconSize = CGSize(width: 16, height: 15)
                        let iconY = currentY + (lineHeight - iconSize.height) / 2 - 3
                        let iconRect = CGRect(x: leftX, y: iconY, width: iconSize.width, height: iconSize.height)
                        iconImage.draw(in: iconRect)
                        leftX += iconSize.width
                    }
                }
                
                // Right part: reps/duration text
                let reps = Int(exercise.logs?.last?.reps ?? 0)
                let rightText: String
                if exercise.units == "Reps" {
                    rightText = "\(reps) reps"
                } else {
                    let minutes = reps / 60
                    let seconds = reps % 60
                    rightText = String(format: "%02d:%02d", minutes, seconds)
                }
                let rightTextSize = (rightText as NSString).size(withAttributes: textAttributes)
                let rightX = imageSize.width - rightMargin - rightTextSize.width
                let rightRect = CGRect(x: rightX, y: currentY, width: rightTextSize.width, height: lineHeight)
                rightText.draw(in: rightRect, withAttributes: textAttributes)
                
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
