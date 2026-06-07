//
//  SignUpView.swift
//  MatchFlow
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var onSwitchToLogin: () -> Void

    private var isSignUpEnabled: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        VStack(spacing: DSSpacing.s24) {
            Spacer()

            headerSection
            inputCard

            if !viewModel.errorMessage.isEmpty {
                AuthErrorBanner(message: viewModel.errorMessage)
            }

            signUpButton

            Spacer()

            loginFooter
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, DSSpacing.s16)
        .padding(.bottom, DSSpacing.s64)
    }

    private var headerSection: some View {
        AuthHeaderView(
            systemImage: "person.badge.key.fill",
            title: "Let's get started",
            subtitle: "Create your account"
        )
    }

    private var inputCard: some View {
        VStack(spacing: 0) {
            TextField("Email", text: $email)
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, DSSpacing.s16)
                .padding(.vertical, DSSpacing.s16)

            Rectangle()
                .fill(Color.borderDefault)
                .frame(height: DSStroke.s1)

            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundPrimary)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color.foregroundSecondary)
                }
            }
            .padding(.horizontal, DSSpacing.s16)
            .padding(.vertical, DSSpacing.s16)
        }
        .background(Color.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.r16))
    }

    private var signUpButton: some View {
        DSButton(
            title: "Sign up",
            isEnabled: isSignUpEnabled,
            isLoading: viewModel.isLoading
        ) {
            Task {
                await viewModel.signUp(email: email, password: password)
            }
        }
    }

    private var loginFooter: some View {
        HStack(spacing: DSSpacing.s4) {
            Text("Already have an account?")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)
            Button(action: onSwitchToLogin) {
                Text("Log in")
                    .textStyle(.body2Semibold)
                    .foregroundStyle(Color.foregroundAccent)
            }
        }
    }
}

#Preview {
    ZStack {
        AuthBackgroundView()
        SignUpView(onSwitchToLogin: {})
    }
    .environmentObject(AuthViewModel())
}
