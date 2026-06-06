//
//  JobsView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI

struct JobsView: View {
    @StateObject private var viewModel = JobsViewModel()
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var tabSelection: TabSelectionViewModel
    @State private var showAddManually = false
    
    var filteredJobs: [Job] {
        guard let filter = tabSelection.jobsFilter else { return viewModel.jobs }
        return viewModel.jobs.filter { $0.status == filter }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", count: viewModel.jobs.count, isSelected: tabSelection.jobsFilter == nil, color: .primary) {
                            tabSelection.jobsFilter = nil
                        }
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            let count = viewModel.jobs.filter { $0.status == status }.count
                            FilterChip(
                                title: JobStatusStyle.label(for: status),
                                count: count,
                                isSelected: tabSelection.jobsFilter == status,
                                color: JobStatusStyle.color(for: status)
                            ) {
                                tabSelection.jobsFilter = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredJobs.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text(tabSelection.jobsFilter == nil ? "No jobs yet" : "No \(tabSelection.jobsFilter!.rawValue) jobs")
                            .font(.headline)
                        if tabSelection.jobsFilter == nil {
                            Text("Share a job from Safari or LinkedIn\nor add manually")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Add Manually") {
                                showAddManually = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredJobs) { job in
                            NavigationLink(destination: JobDetailView(job: job)) {
                                JobRowView(job: job)
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                await viewModel.deleteJobs(at: indexSet, from: filteredJobs)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Jobs (\(viewModel.jobs.count))")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddManually = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddManually) {
                AddJobView(viewModel: viewModel, userId: auth.currentUserId)
            }
            .task {
                await viewModel.load(userId: auth.currentUserId)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await viewModel.load(userId: auth.currentUserId)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.15) : Color(.systemGray6))
            .foregroundColor(isSelected ? color : .secondary)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    JobsView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabSelectionViewModel())
}
