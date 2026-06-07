import SwiftUI

struct DSTextStyle {
    let font: Font
    let kerning: CGFloat

    static let title1 = DSTextStyle(
        font: .system(size: 60, weight: .bold),
        kerning: 0.24
    )
    static let title2 = DSTextStyle(
        font: .system(size: 34, weight: .bold),
        kerning: 0.4
    )
    static let header1 = DSTextStyle(
        font: .system(size: 24, weight: .bold),
        kerning: 0
    )
    static let body1Regular = DSTextStyle(
        font: .system(size: 17, weight: .regular),
        kerning: -0.43
    )
    static let body1Semibold = DSTextStyle(
        font: .system(size: 17, weight: .semibold),
        kerning: -0.43
    )
    static let body2Regular = DSTextStyle(
        font: .system(size: 15, weight: .regular),
        kerning: 0
    )
    static let body2Semibold = DSTextStyle(
        font: .system(size: 15, weight: .semibold),
        kerning: 0
    )
    static let captionRegular = DSTextStyle(
        font: .system(size: 13, weight: .regular),
        kerning: 0
    )
    static let captionSemibold = DSTextStyle(
        font: .system(size: 13, weight: .semibold),
        kerning: 0
    )
}

extension View {
    func textStyle(_ style: DSTextStyle) -> some View {
        font(style.font)
            .kerning(style.kerning)
    }
}
