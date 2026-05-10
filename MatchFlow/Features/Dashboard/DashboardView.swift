//
//  DashboardView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI
import Supabase
import Auth

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var tabSelection: TabSelectionViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - This Week
                Section {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("\(viewModel.jobsThisWeek) jobs added this week")
                            .font(.subheadline)
                    }
                }
                
                // MARK: - Status Grid
                Section {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            StatusCard(
                                status: status,
                                count: viewModel.jobs(for: status).count
                            ) {
                                tabSelection.selectedTab = 1
                                tabSelection.jobsFilter = status
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Top Matches
                if !viewModel.topMatches.isEmpty {
                    Section("Top Matches") {
                        ForEach(viewModel.topMatches) { job in
                            NavigationLink(destination: JobDetailView(job: job)) {
                                TopMatchRow(job: job)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            .task {
                if let session = try? await supabase.auth.session,
                   let uuid = UUID(uuidString: session.user.id.uuidString) {
                    await viewModel.load(userId: uuid)
                }
            }
            .refreshable {
                if let session = try? await supabase.auth.session,
                   let uuid = UUID(uuidString: session.user.id.uuidString) {
                    await viewModel.load(userId: uuid)
                }
            }
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    let status: JobStatus
    let count: Int
    let action: () -> Void
    
    var color: Color {
        switch status {
        case .applied: return .blue
        case .interview: return .orange
        case .rejected: return .red
        case .offer: return .green
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(count)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(status.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.08))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Top Match Row
struct TopMatchRow: View {
    let job: Job
    
    var color: Color {
        guard let score = job.matchScore else { return .secondary }
        return score >= 0.55 ? .green : score >= 0.45 ? .orange : .red
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(job.title ?? "Unknown Role")
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 6) {
                    Text(job.company ?? "Unknown Company")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 3, height: 3)
                    StatusBadge(status: job.status)
                }
            }
            Spacer()
            if let score = job.matchScore {
                Text("\(Int(score * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(TabSelectionViewModel())
}
