//
//  AuthFlowView.swift
//  MatchFlow
//

import SwiftUI

enum AuthRoute: Hashable {
    case login
    case signUp
}

private extension AnyTransition {
    static var authPushInsertion: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }

    static var authIntroRemoval: AnyTransition {
        .asymmetric(
            insertion: .opacity,
            removal: .move(edge: .leading)
        )
    }
}

struct AuthFlowView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var route: AuthRoute?

    var body: some View {
        ZStack {
            if route == .login || route == .signUp {
                AuthBackgroundView()
            }

            if route == nil {
                IntroView(
                    onLogin: { withAnimation(.easeInOut(duration: 0.35)) { route = .login } },
                    onSignUp: { withAnimation(.easeInOut(duration: 0.35)) { route = .signUp } }
                )
                .opacity(auth.isCheckingSession || auth.isAuthenticated ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: auth.isCheckingSession)
                .allowsHitTesting(!auth.isCheckingSession)
                .transition(.authIntroRemoval)
            }

            if route == .login {
                LoginView(onRegister: switchToSignUp)
                    .transition(.authPushInsertion)
            }

            if route == .signUp {
                SignUpView(onSwitchToLogin: switchToLogin)
                    .transition(.authPushInsertion)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .animation(.easeInOut(duration: 0.35), value: route)
        .onChange(of: route) {
            auth.errorMessage = ""
        }
    }

    private func switchToSignUp() {
        guard route != .signUp else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            route = .signUp
        }
    }

    private func switchToLogin() {
        guard route == .signUp else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            route = .login
        }
    }
}

#Preview {
    ZStack {
        SplashBackgroundView()
        AuthFlowView()
    }
    .environmentObject(AuthViewModel())
}
