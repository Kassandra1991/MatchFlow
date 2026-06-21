//
//  SkillTag.swift
//  MatchFlow
//

import SwiftUI

struct SkillTag: View {
    enum Style {
        case accent
        case neutral
        case primary
    }

    let name: String
    var style: Style = .accent

    var body: some View {
        Text(name)
            .textStyle(.captionRegular)
            .padding(.horizontal, DSSpacing.s8 + DSSpacing.s2)
            .padding(.vertical, DSSpacing.s4)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch style {
        case .accent: Color.backgroundAccent
        case .neutral: Color.backgroundMinor
        case .primary: Color.backgroundPrimary
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .accent: Color.foregroundAccent
        case .neutral: Color.foregroundSecondary
        case .primary: Color.foregroundSecondary
        }
    }
}
