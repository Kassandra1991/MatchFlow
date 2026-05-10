//
//  AuthView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI


struct AuthView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        VStack(spacing: 24) {
            Text("MatchFlow")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button {
                Task {
                    if isSignUp {
                        await viewModel.signUp(email: email, password: password)
                    } else {
                        await viewModel.signIn(email: email, password: password)
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Button(isSignUp ? "Already have an account? Sign In" : "No account? Sign Up") {
                isSignUp.toggle()
            }
            .font(.caption)
        }
        .padding(32)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
