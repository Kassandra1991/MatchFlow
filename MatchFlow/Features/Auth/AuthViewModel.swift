//
//  AuthViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            try await supabase.auth.signUp(
                email: email,
                password: password
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            try await supabase.auth.signIn(
                email: email,
                password: password
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func checkSession() async {
        do {
            _ = try await supabase.auth.session
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }
}
