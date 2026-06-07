//
//  DSButton.swift
//  MatchFlow
//

import SwiftUI

struct DSButton: View {
    let title: String
    var size: DSButtonSize = .large
    var variant: DSButtonVariant = .primary
    var width: DSButtonWidth = .fill
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    private var backgroundColor: Color {
        variant.backgroundColor(isEnabled: isEnabled)
    }

    private var foregroundColor: Color {
        variant.foregroundColor(isEnabled: isEnabled)
    }

    var body: some View {
        Button(action: action) {
            label
                .frame(minHeight: max(size.height, DSButtonSize.minHitHeight))
                .frame(maxWidth: width == .fill ? .infinity : nil)
                .contentShape(Rectangle())
        }
        .disabled(!isEnabled || isLoading)
    }

    private var label: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(foregroundColor)
            } else {
                Text(title)
                    .textStyle(size.textStyle)
                    .lineSpacing(size.lineSpacing)
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, size.horizontalPadding)
        .frame(height: size.height)
        .frame(maxWidth: width == .fill ? .infinity : nil)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: DSSpacing.s16) {
        DSButton(title: "Log in", variant: .onDarkSecondary) {}
        DSButton(title: "Sign up", variant: .secondaryWhite) {}
        DSButton(title: "Log in", variant: .primary, isEnabled: true) {}
        DSButton(title: "Log in", variant: .primary, isEnabled: false) {}
    }
    .padding()
}
