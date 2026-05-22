//
//  MainTabView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var tabSelection = TabSelectionViewModel()
    
    var body: some View {
        TabView(selection: $tabSelection.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Insights", systemImage: "sparkles")
                }
                .tag(0)
                .onAppear { AnalyticsService.log(.tabOpened(name: "insights")) }
            
            JobsView()
                .tabItem {
                    Label("Jobs", systemImage: "briefcase")
                }
                .tag(1)
                .onAppear { AnalyticsService.log(.tabOpened(name: "jobs")) }
            
            ResumeView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
                .onAppear { AnalyticsService.log(.tabOpened(name: "profile")) }
        }
        .environmentObject(tabSelection)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
