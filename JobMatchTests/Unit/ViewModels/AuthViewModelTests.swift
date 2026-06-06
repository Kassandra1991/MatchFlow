//
//  AuthViewModelTests.swift
//  JobMatchTests
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("AuthViewModel")
struct AuthViewModelTests {
    @Test("Sign in sets authenticated state and user id")
    func signInSetsAuthenticatedState() async {
        let mockService = MockAuthService()
        mockService.currentUserIdValue = UUID()
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.signIn(email: "test@example.com", password: "password")

        let isAuthenticated = await viewModel.isAuthenticated
        let userId = await viewModel.currentUserId
        #expect(isAuthenticated)
        #expect(userId != nil)
        #expect(mockService.signInCalled)
    }

    @Test("Sign in sets error on failure")
    func signInSetsErrorOnFailure() async {
        let mockService = MockAuthService()
        mockService.shouldThrow = true
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.signIn(email: "test@example.com", password: "password")

        let error = await viewModel.errorMessage
        let isAuthenticated = await viewModel.isAuthenticated
        #expect(!error.isEmpty)
        #expect(!isAuthenticated)
    }

    @Test("Check session clears state when no session")
    func checkSessionClearsStateOnFailure() async {
        let mockService = MockAuthService()
        mockService.shouldThrow = true
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.checkSession()

        let isAuthenticated = await viewModel.isAuthenticated
        let userId = await viewModel.currentUserId
        #expect(!isAuthenticated)
        #expect(userId == nil)
        #expect(mockService.checkSessionCalled)
    }

    @Test("Sign out clears authenticated state")
    func signOutClearsState() async {
        let mockService = MockAuthService()
        mockService.isAuthenticated = true
        mockService.currentUserIdValue = UUID()
        let viewModel = await AuthViewModel(authService: mockService)
        await MainActor.run {
            viewModel.isAuthenticated = true
            viewModel.currentUserId = mockService.currentUserIdValue
        }

        await viewModel.signOut()

        let isAuthenticated = await viewModel.isAuthenticated
        let userId = await viewModel.currentUserId
        #expect(!isAuthenticated)
        #expect(userId == nil)
        #expect(mockService.signOutCalled)
    }
}
