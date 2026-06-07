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
            ZStack {
                if auth.isAuthenticated {
                    MainTabView()
                        .environmentObject(auth)
                        .environmentObject(tabSelection)
                        .opacity(auth.showMainUI ? 1 : 0)
                        .zIndex(0)
                }

                if !auth.showMainUI {
                    UnauthenticatedContainer()
                        .environmentObject(auth)
                        .opacity(auth.showMainUI ? 0 : 1)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: auth.showMainUI)
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
