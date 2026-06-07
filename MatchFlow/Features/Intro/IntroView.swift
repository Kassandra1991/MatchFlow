//
//  IntroView.swift
//  MatchFlow
//

import SwiftUI

struct IntroView: View {
    var onLogin: () -> Void
    var onSignUp: () -> Void

    var body: some View {
        ZStack {
            SplashBackgroundView()

            VStack(spacing: 0) {
                Spacer()

                headlineBlock

                Spacer()

                buttonStack
            }
        }
        .navigationBarHidden(true)
    }

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s24) {
            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                Text("Find gaps.")
                    .textStyle(.title1)
                Text("Improve CV.")
                    .textStyle(.title1)
                Text("Get hired.")
                    .textStyle(.title1)
            }
            .foregroundStyle(Color.foregroundPrimaryWhite)

            Text("AI-powered CV matching")
                .textStyle(.body1Semibold)
                .lineSpacing(5)
                .foregroundStyle(Color.foregroundPrimaryWhite)
        }
        .padding(DSSpacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, DSSpacing.s16)
    }

    private var buttonStack: some View {
        VStack(spacing: DSSpacing.s16) {
            DSButton(title: "Log in", variant: .onDarkSecondary, action: onLogin)
            DSButton(title: "Sign up", variant: .secondaryWhite, action: onSignUp)
        }
        .padding(.horizontal, DSSpacing.s16)
        .padding(.bottom, DSSpacing.s64)
    }
}

#Preview {
    IntroView(onLogin: {}, onSignUp: {})
}
