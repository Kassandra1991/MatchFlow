//
//  AuthViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showMainUI = false
    @Published var currentUserId: UUID?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isCheckingSession = true

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            try await authService.signUp(email: email, password: password)
            currentUserId = try await authService.currentUserId()
            withAnimation(.easeInOut(duration: 0.5)) {
                isAuthenticated = true
                showMainUI = true
            }
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
            try await authService.signIn(email: email, password: password)
            currentUserId = try await authService.currentUserId()
            withAnimation(.easeInOut(duration: 0.5)) {
                isAuthenticated = true
                showMainUI = true
            }
            AnalyticsService.log(.signIn)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        isAuthenticated = false
        showMainUI = false
        isCheckingSession = false
        currentUserId = nil
    }

    func checkSession() async {
        isCheckingSession = true
        var hasSession = false
        do {
            try await authService.checkSession()
            hasSession = true
            currentUserId = try await authService.currentUserId()
        } catch {
            isAuthenticated = false
            currentUserId = nil
        }
        // Minimum splash logo display before revealing intro/auth UI
        try? await Task.sleep(nanoseconds: 800_000_000)
        if hasSession {
            isAuthenticated = true
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            if hasSession {
                showMainUI = true
            } else {
                isCheckingSession = false
            }
        }
    }
}
