//
//  UnauthenticatedContainer.swift
//  MatchFlow
//

import SwiftUI

struct UnauthenticatedContainer: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var route: AuthRoute?

    var body: some View {
        ZStack {
            if auth.isCheckingSession || route == nil {
                SplashBackgroundView()
                    .ignoresSafeArea()
                    .transition(.identity)
            }

            if route == .login || route == .signUp {
                AuthBackgroundView()
                    .ignoresSafeArea()
                    .transition(.identity)
            }

            AuthFlowView(route: $route)

            SplashLogoView()
                .opacity(auth.isCheckingSession ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: auth.isCheckingSession)
                .allowsHitTesting(auth.isCheckingSession)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.35), value: route)
    }
}

#Preview {
    UnauthenticatedContainer()
        .environmentObject(AuthViewModel())
}
