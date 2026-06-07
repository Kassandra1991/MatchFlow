//
//  MatchFlowApp.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI
import FirebaseCore

@main
struct MatchFlowApp: App {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var tabSelection = TabSelectionViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isCheckingSession {
                    SplashView()
                } else if auth.isAuthenticated {
                    MainTabView()
                        .environmentObject(auth)
                        .environmentObject(tabSelection)
                } else {
                    AuthView()
                        .environmentObject(auth)
                }
            }
            .task {
                await auth.checkSession()
            }
            .onOpenURL { url in
                if url.scheme == "jobmatch" {
                    tabSelection.selectedTab = 1
                    tabSelection.jobsFilter = .exploring
                }
            }
        }
    }
}
