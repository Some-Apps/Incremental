import Foundation
import SwiftUI

final class ColorSchemeState: ObservableObject {
    @Published private var currentColorSchemeType: MyColorSchemeType

    init() {
        // Load saved color scheme type from UserDefaults, defaulting to .main
        if let savedType = UserDefaults.standard.string(forKey: "SelectedColorScheme"),
           let savedSchemeType = MyColorSchemeType(rawValue: savedType) {
            self.currentColorSchemeType = savedSchemeType
        } else {
            self.currentColorSchemeType = .main
        }
    }

    var current: MyColorScheme {
        return currentColorSchemeType.colorScheme
    }

    func updateColorScheme(to colorSchemeType: MyColorSchemeType) {
        self.currentColorSchemeType = colorSchemeType
        // Save the selected color scheme type to UserDefaults
        UserDefaults.standard.set(colorSchemeType.rawValue, forKey: "SelectedColorScheme")
    }
}


struct MyColorScheme {
    let title: String
    
    let primaryBackground: Color
    let secondaryBackground: Color
    let tertiaryBackground: Color
    let cardBackground: Color
    let accentText: Color
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
}

enum MyColorSchemeType: String, CaseIterable, RandomAccessCollection {
    case main = "Default"
    case alternative = "Forest"

    private static let mainCs: MyColorScheme = MyColorScheme(
        title: "Default", 
        primaryBackground: Color.dynamic(light: "FFFFFF", dark: "000000"),
        secondaryBackground: Color.dynamic(light: "F5F5F5", dark: "131313"),
        tertiaryBackground: Color.dynamic(light: "FFFFFF", dark: "232323"),
        cardBackground: Color.dynamic(light: "FFFFFF", dark: "000000"),
        accentText: Color.dynamic(light: "008CFF", dark: "008CFF"),
        primaryText: Color.dynamic(light: "000000", dark: "FFFFFF"),
        secondaryText: Color.dynamic(light: "7D7D7D", dark: "828282"),
        tertiaryText: Color.dynamic(light: "B3B3B3", dark: "4D4D4D")
    )
    
    private static let altCs: MyColorScheme = MyColorScheme(
        title: "Forest",
        primaryBackground: Color.dynamic(light: "FFFFFF", dark: "232323"),
        secondaryBackground: Color.dynamic(light: "F5F5F5", dark: "000000"),
        tertiaryBackground: Color.dynamic(light: "FFFFFF", dark: "232323"),
        cardBackground: Color.dynamic(light: "FFFFFF", dark: "000000"),
        accentText: Color.dynamic(light: "008CFF", dark: "008CFF"),
        primaryText: Color.dynamic(light: "000000", dark: "FFFFFF"),
        secondaryText: Color.dynamic(light: "7D7D7D", dark: "828282"),
        tertiaryText: Color.dynamic(light: "B3B3B3", dark: "4D4D4D")
    )

    var colorScheme: MyColorScheme {
        switch self {
        case .main:
          return MyColorSchemeType.mainCs
        case .alternative:
          return MyColorSchemeType.altCs
        }
    }
}








extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, alpha: Double(a) / 255)
    }
}

extension UIColor {
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return light } // feel free to omit this if you are targeting only later iOS versions
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

extension UIColor {
    // helper to convert from UIColor -> Color
    func toColor() -> Color {
        return Color(uiColor: self)
    }
}
extension Color {
    static func dynamic(light: String, dark: String) -> Color {
        let l = UIColor(hex: light)
        let d = UIColor(hex: dark)
        return UIColor.dynamicColor(light: l, dark: d).toColor()
    }
}

// Example shared instance to manage the color scheme state globally
class ColorSchemeManager {
    static let shared = ColorSchemeManager()
    let colorSchemeState = ColorSchemeState() // Assuming this is the ColorSchemeState from your code
}

extension Color {
    // Access current color scheme dynamically from ColorSchemeManager
    static var currentScheme: MyColorScheme {
        return ColorSchemeManager.shared.colorSchemeState.current
    }

    // Define custom color properties based on current scheme
    static var primaryBackground: Color {
        return currentScheme.primaryBackground
    }

    static var secondaryBackground: Color {
        return currentScheme.secondaryBackground
    }

    static var tertiaryBackground: Color {
        return currentScheme.tertiaryBackground
    }

    static var cardBackground: Color {
        return currentScheme.cardBackground
    }

    static var accentText: Color {
        return currentScheme.accentText
    }

    static var primaryText: Color {
        return currentScheme.primaryText
    }

    static var secondaryText: Color {
        return currentScheme.secondaryText
    }

    static var tertiaryText: Color {
        return currentScheme.tertiaryText
    }
}
