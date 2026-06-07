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
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            IntroView(
                onLogin: { path.append(.login) },
                onSignUp: { path.append(.signUp) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .login:
                    LoginView(onRegister: switchToSignUp)
                case .signUp:
                    SignUpView(onSwitchToLogin: switchToLogin)
                }
            }
        }
        .onChange(of: path) {
            auth.errorMessage = ""
        }
    }

    private func switchToSignUp() {
        guard path.last != .signUp else { return }
        path.append(.signUp)
    }

    private func switchToLogin() {
        guard path.last == .signUp else { return }
        if path.dropLast().last == .login {
            path.removeLast()
        } else {
            path = [.login]
        }
    }
}

#Preview {
    AuthFlowView()
        .environmentObject(AuthViewModel())
}
