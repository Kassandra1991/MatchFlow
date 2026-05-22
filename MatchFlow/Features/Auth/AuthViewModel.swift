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
    @Published var isCheckingSession = true

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            try await supabase.auth.signUp(
                email: email,
                password: password
            )
            isAuthenticated = true
            AnalyticsService.log(.signUp)
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
            AnalyticsService.log(.signIn)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func checkSession() async {
        isCheckingSession = true
        do {
            _ = try await supabase.auth.session
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 секунды
        isCheckingSession = false
    }
}
