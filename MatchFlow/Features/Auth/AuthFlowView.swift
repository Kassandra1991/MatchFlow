//
//  AuthFlowView.swift
//  MatchFlow
//

import SwiftUI

enum AuthRoute: Hashable {
    case login
    case signUp
}

struct AuthFlowView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var route: AuthRoute?

    var body: some View {
        ZStack {
            if route == nil {
                IntroView(
                    onLogin: { route = .login },
                    onSignUp: { route = .signUp }
                )
                .opacity(auth.isCheckingSession || auth.isAuthenticated ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: auth.isCheckingSession)
                .allowsHitTesting(!auth.isCheckingSession)
            }

            if let route {
                authScreen(for: route)
            }
        }
        .onChange(of: route) {
            auth.errorMessage = ""
        }
    }

    @ViewBuilder
    private func authScreen(for route: AuthRoute) -> some View {
        switch route {
        case .login:
            LoginView(
                onRegister: switchToSignUp,
                onBack: { self.route = nil }
            )
        case .signUp:
            SignUpView(
                onSwitchToLogin: switchToLogin,
                onBack: { self.route = nil }
            )
        }
    }

    private func switchToSignUp() {
        guard route != .signUp else { return }
        route = .signUp
    }

    private func switchToLogin() {
        guard route == .signUp else { return }
        route = .login
    }
}

#Preview {
    ZStack {
        SplashBackgroundView()
        AuthFlowView()
    }
    .environmentObject(AuthViewModel())
}
