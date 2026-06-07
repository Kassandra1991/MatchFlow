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
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        #expect(isAuthenticated)
        #expect(showMainUI)
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
        let showMainUI = await viewModel.showMainUI
        #expect(!error.isEmpty)
        #expect(!isAuthenticated)
        #expect(!showMainUI)
    }

    @Test("Sign up sets authenticated state and user id")
    func signUpSetsAuthenticatedState() async {
        let mockService = MockAuthService()
        mockService.currentUserIdValue = UUID()
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.signUp(email: "test@example.com", password: "password")

        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        #expect(isAuthenticated)
        #expect(showMainUI)
        #expect(userId != nil)
        #expect(mockService.signUpCalled)
    }

    @Test("Sign up sets error on failure")
    func signUpSetsErrorOnFailure() async {
        let mockService = MockAuthService()
        mockService.shouldThrow = true
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.signUp(email: "test@example.com", password: "password")

        let error = await viewModel.errorMessage
        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        #expect(!error.isEmpty)
        #expect(!isAuthenticated)
        #expect(!showMainUI)
        #expect(mockService.signUpCalled)
    }

    @Test("Sign up does not authenticate when session is missing after sign up")
    func signUpDoesNotAuthenticateWithoutSession() async {
        let mockService = MockAuthService()
        mockService.shouldThrowOnCurrentUserId = true
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.signUp(email: "test@example.com", password: "password")

        let error = await viewModel.errorMessage
        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        #expect(!error.isEmpty)
        #expect(!isAuthenticated)
        #expect(!showMainUI)
        #expect(userId == nil)
        #expect(mockService.signUpCalled)
    }

    @Test("Sign in does not authenticate when session is missing after sign in")
    func signInDoesNotAuthenticateWithoutSession() async {
        let mockService = MockAuthService()
        mockService.shouldThrowOnCurrentUserId = true
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.signIn(email: "test@example.com", password: "password")

        let error = await viewModel.errorMessage
        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        #expect(!error.isEmpty)
        #expect(!isAuthenticated)
        #expect(!showMainUI)
        #expect(userId == nil)
        #expect(mockService.signInCalled)
    }

    @Test("Check session sets authenticated state when session exists")
    func checkSessionSetsAuthenticatedState() async {
        let mockService = MockAuthService()
        mockService.isAuthenticated = true
        mockService.currentUserIdValue = UUID()
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.checkSession()

        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        let isCheckingSession = await viewModel.isCheckingSession
        #expect(isAuthenticated)
        #expect(showMainUI)
        #expect(userId != nil)
        #expect(isCheckingSession)
        #expect(mockService.checkSessionCalled)
    }

    @Test("Check session clears state when no session")
    func checkSessionClearsStateOnFailure() async {
        let mockService = MockAuthService()
        mockService.shouldThrow = true
        let viewModel = await AuthViewModel(authService: mockService)

        await viewModel.checkSession()

        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        #expect(!isAuthenticated)
        #expect(!showMainUI)
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
            viewModel.showMainUI = true
            viewModel.currentUserId = mockService.currentUserIdValue
        }

        await viewModel.signOut()

        let isAuthenticated = await viewModel.isAuthenticated
        let showMainUI = await viewModel.showMainUI
        let userId = await viewModel.currentUserId
        let isCheckingSession = await viewModel.isCheckingSession
        #expect(!isAuthenticated)
        #expect(!showMainUI)
        #expect(userId == nil)
        #expect(!isCheckingSession)
        #expect(mockService.signOutCalled)
    }
}
