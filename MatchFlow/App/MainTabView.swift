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
            
            JobsView()
                .tabItem {
                    Label("Jobs", systemImage: "briefcase")
                }
                .tag(1)
            
            ResumeView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .environmentObject(tabSelection)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
