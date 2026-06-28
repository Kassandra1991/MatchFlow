//
//  MainTabView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var jobsViewModel = JobsViewModel()
    @EnvironmentObject private var tabSelection: TabSelectionViewModel

    var body: some View {
        TabView(selection: $tabSelection.selectedTab) {
            InsightsView()
                .environmentObject(jobsViewModel)
                .tabItem {
                    Label("Insights", systemImage: "sparkle")
                }
                .tag(0)
                .onAppear { AnalyticsService.log(.tabOpened(name: "insights")) }

            JobsView()
                .environmentObject(jobsViewModel)
                .tabItem {
                    Label("Jobs", systemImage: "case.fill")
                }
                .tag(1)
                .onAppear { AnalyticsService.log(.tabOpened(name: "jobs")) }

            ResumeView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
                .onAppear { AnalyticsService.log(.tabOpened(name: "profile")) }
        }
        .tint(Color.foregroundAccent)
        .environmentObject(tabSelection)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabSelectionViewModel())
}
