//
//  LoginView.swift
//  MatchFlow
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthViewModel

    var onRegister: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    private var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        VStack(spacing: DSSpacing.s24) {
            Spacer()

            headerSection
            inputCard
            loginButton

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundError)
                    .multilineTextAlignment(.center)
            }

            forgotPasswordRow

            Spacer()

            registerFooter
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, DSSpacing.s16)
        .padding(.bottom, DSSpacing.s64)
    }

    private var headerSection: some View {
        AuthHeaderView(
            systemImage: "person.crop.circle",
            title: "Welcome back",
            subtitle: "Log in to your account"
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

    private var loginButton: some View {
        DSButton(
            title: "Log in",
            isEnabled: isLoginEnabled,
            isLoading: viewModel.isLoading
        ) {
            Task {
                await viewModel.signIn(email: email, password: password)
            }
        }
    }

    private var forgotPasswordRow: some View {
        HStack(spacing: DSSpacing.s4) {
            Text("Forgot your password?")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)
            Button {
                // TODO: reset password flow
            } label: {
                Text("Reset")
                    .textStyle(.body2Semibold)
                    .foregroundStyle(Color.foregroundAccent)
            }
        }
    }

    private var registerFooter: some View {
        HStack(spacing: DSSpacing.s4) {
            Text("Don't have an account?")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)
            Button(action: onRegister) {
                Text("Register now")
                    .textStyle(.body2Semibold)
                    .foregroundStyle(Color.foregroundAccent)
            }
        }
    }
}

#Preview {
    ZStack {
        AuthBackgroundView()
        LoginView(onRegister: {})
    }
    .environmentObject(AuthViewModel())
}
