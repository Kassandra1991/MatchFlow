//
//  MockAuthService.swift
//  JobMatchTests
//

import Foundation
@testable import MatchFlow

class MockAuthService: AuthServiceProtocol {
    var isAuthenticated = false
    var currentUserIdValue: UUID?
    var shouldThrow = false
    var shouldThrowOnCurrentUserId = false

    var signUpCalled = false
    var signInCalled = false
    var signOutCalled = false
    var checkSessionCalled = false

    func signUp(email: String, password: String) async throws {
        signUpCalled = true
        if shouldThrow { throw TestError.mock }
        isAuthenticated = true
        currentUserIdValue = currentUserIdValue ?? UUID()
    }

    func signIn(email: String, password: String) async throws {
        signInCalled = true
        if shouldThrow { throw TestError.mock }
        isAuthenticated = true
        currentUserIdValue = currentUserIdValue ?? UUID()
    }

    func signOut() async throws {
        signOutCalled = true
        if shouldThrow { throw TestError.mock }
        isAuthenticated = false
        currentUserIdValue = nil
    }

    func checkSession() async throws {
        checkSessionCalled = true
        if shouldThrow { throw TestError.mock }
        guard isAuthenticated else { throw TestError.mock }
    }

    func currentUserId() async throws -> UUID? {
        if shouldThrow || shouldThrowOnCurrentUserId { throw TestError.mock }
        return currentUserIdValue
    }
}
