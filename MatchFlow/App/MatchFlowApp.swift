//
//  MatchFlowApp.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI

@main
struct MatchFlowApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    Text("Welcome!")
                } else {
                    AuthView()
                }
            }
            .environmentObject(auth)
            .task {
                await auth.checkSession()
            }
        }
    }
}
