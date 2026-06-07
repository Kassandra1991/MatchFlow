//
//  SplashView.swift
//  MatchFlow
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Image("SplashBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: DSSpacing.s24) {
                logoLockup
                ProgressView()
                    .tint(.foregroundPrimaryWhite)
            }
        }
    }

    private var logoLockup: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Job")
                    .textStyle(.title1)
                Text("Match")
                    .textStyle(.title1)
            }
            .foregroundStyle(Color.foregroundPrimaryWhite)

            Image(systemName: "sparkle")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(Color.foregroundPrimaryWhite)
                .offset(x: 72, y: -36)
        }
    }
}

#Preview {
    SplashView()
}
