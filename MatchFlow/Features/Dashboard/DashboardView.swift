//
//  DashboardView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var tabSelection: TabSelectionViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.vertical, 20)
                            Spacer()
                        }
                    } else {
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
                
                    if viewModel.isLoadingInsights {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Analyzing ...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else if let insights = viewModel.insights {
                        if let summary = insights.summary {
                            Text(summary)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                        }
                    } else if !viewModel.allJobs.isEmpty {
                        Button {
                            Task { await viewModel.generateInsights() }
                        } label: {
                            Label("Generate Insights", systemImage: "sparkles")
                        }
                    } else {
                        Text("Add jobs to get AI insights")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
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
            .navigationTitle("Insights")
            .task {
                if let userId = auth.currentUserId {
                    await viewModel.load(userId: userId)
                }
            }
            .refreshable {
                if let userId = auth.currentUserId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }
}

struct StatusCard: View {
    let status: JobStatus
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(count)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.foregroundPrimary)
                Text(JobStatusStyle.label(for: status))
                    .font(.subheadline)
                    .foregroundStyle(Color.foregroundSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.backgroundSecondary)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

struct TopMatchRow: View {
    let job: Job
    
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
                let tier = MatchScoreTier(score: score)
                let percent = Int(score * 100)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(tier == .excellent ? "Excellent" : "\(percent)%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(tier.foregroundColor)
                    if tier == .excellent {
                        Text("\(percent)%")
                            .font(.caption2)
                            .foregroundColor(tier.foregroundColor)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tier.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabSelectionViewModel())
}
