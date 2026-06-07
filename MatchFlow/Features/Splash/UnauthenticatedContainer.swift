//
//  UnauthenticatedContainer.swift
//  MatchFlow
//

import SwiftUI

struct UnauthenticatedContainer: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        ZStack {
            SplashBackgroundView()

            AuthFlowView()

            SplashLogoView()
                .opacity(auth.isCheckingSession ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: auth.isCheckingSession)
                .allowsHitTesting(auth.isCheckingSession)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UnauthenticatedContainer()
        .environmentObject(AuthViewModel())
}
