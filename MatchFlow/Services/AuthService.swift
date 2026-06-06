//
//  AuthService.swift
//  MatchFlow
//

import Foundation
import Supabase

protocol AuthServiceProtocol {
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func checkSession() async throws
    func currentUserId() async throws -> UUID?
}

struct AuthService: AuthServiceProtocol {
    func signUp(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    func checkSession() async throws {
        _ = try await supabase.auth.session
    }

    func currentUserId() async throws -> UUID? {
        let session = try await supabase.auth.session
        return UUID(uuidString: session.user.id.uuidString)
    }
}
