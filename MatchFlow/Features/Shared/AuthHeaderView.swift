//
//  AuthHeaderView.swift
//  MatchFlow
//

import SwiftUI

struct AuthHeaderView: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: DSSpacing.s16) {
            Image(systemName: systemImage)
                .font(.system(size: 34))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.foregroundAccent)
                .frame(width: 34, height: 41)

            Text(title)
                .textStyle(.title2)
                .foregroundStyle(Color.foregroundPrimary)

            Text(subtitle)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundSecondary)
        }
    }
}

#Preview {
    ZStack {
        AuthBackgroundView()
        AuthHeaderView(
            systemImage: "person.crop.circle",
            title: "Welcome back",
            subtitle: "Log in to your account"
        )
    }
}
