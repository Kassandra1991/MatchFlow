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
    var onBack: () -> Void

    private var isSignUpEnabled: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            VStack(spacing: DSSpacing.s24) {
                backButton

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
            .padding(.horizontal, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s24)
        }
        .onAppear {
            viewModel.errorMessage = ""
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.foregroundPrimaryWhite)
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.s16)
        .padding(.top, DSSpacing.s8)
    }

    private var headerSection: some View {
        VStack(spacing: DSSpacing.s8) {
            Image(systemName: "person.badge.key")
                .font(.system(size: 40))
                .foregroundStyle(Color.foregroundAccent)

            Text("Let's get started")
                .textStyle(.title2)
                .foregroundStyle(Color.foregroundPrimary)

            Text("Create your account")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)
        }
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
    SignUpView(onSwitchToLogin: {}, onBack: {})
        .environmentObject(AuthViewModel())
}
