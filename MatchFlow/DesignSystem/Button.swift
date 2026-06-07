import SwiftUI

enum DSButtonSize {
    case large
    case medium
    case small

    static let minHitHeight: CGFloat = 44

    var height: CGFloat {
        switch self {
        case .large: 54
        case .medium: 38
        case .small: 28
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .large, .medium: 22
        case .small: 19.5
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .large, .medium: DSSpacing.s24
        case .small: DSSpacing.s16
        }
    }

    var textStyle: DSTextStyle {
        switch self {
        case .large: .body1Semibold
        case .medium: .body2Semibold
        case .small: .captionSemibold
        }
    }

    var lineSpacing: CGFloat {
        lineHeight - fontSize
    }

    private var fontSize: CGFloat {
        switch self {
        case .large: 17
        case .medium: 15
        case .small: 13
        }
    }
}

enum DSButtonVariant {
    case primary
    case secondaryWhite
    case onDarkSecondary

    func backgroundColor(isEnabled: Bool) -> Color {
        switch self {
        case .primary:
            isEnabled ? Color.buttonPrimary : Color.buttonSecondary
        case .secondaryWhite:
            Color.buttonSecondaryWhite
        case .onDarkSecondary:
            Color.backgroundSecondary
        }
    }

    func foregroundColor(isEnabled: Bool) -> Color {
        switch self {
        case .primary, .secondaryWhite:
            Color.foregroundPrimaryWhite
        case .onDarkSecondary:
            Color.foregroundAccent
        }
    }
}

enum DSButtonWidth {
    case fill
    case hug
}
