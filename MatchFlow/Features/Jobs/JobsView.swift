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
    @State private var selectedJobId: UUID?

    private var filteredJobs: [Job] {
        guard let filter = tabSelection.jobsFilter else { return viewModel.jobs }
        return viewModel.jobs.filter { $0.status == filter }
    }

    var body: some View {
        NavigationStack {
            jobsContent
                .safeAreaInset(edge: .top, spacing: 0) {
                    statusFilterBar
                }
                .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddManually = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.foregroundPrimary)
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

    @ViewBuilder
    private var jobsContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredJobs.isEmpty {
            JobsEmptyStateView(filter: tabSelection.jobsFilter)
        } else {
            List {
                ForEach(filteredJobs) { job in
                    Button {
                        selectedJobId = job.id
                    } label: {
                        JobRowView(job: job)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    Task {
                        await viewModel.deleteJobs(at: indexSet, from: filteredJobs)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationDestination(item: $selectedJobId) { jobId in
                if let job = viewModel.jobs.first(where: { $0.id == jobId }) {
                    JobDetailView(job: job)
                }
            }
        }
    }

    private var statusFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.s8) {
                FilterChip(title: "All", count: viewModel.jobs.count, isSelected: tabSelection.jobsFilter == nil) {
                    tabSelection.jobsFilter = nil
                }
                ForEach(JobStatus.allCases, id: \.self) { status in
                    let count = viewModel.jobs.filter { $0.status == status }.count
                    FilterChip(
                        title: JobStatusStyle.label(for: status),
                        count: count,
                        isSelected: tabSelection.jobsFilter == status
                    ) {
                        tabSelection.jobsFilter = status
                    }
                }
            }
            .padding(.horizontal, DSSpacing.s16)
            .padding(.vertical, DSSpacing.s8)
        }
        .scrollClipDisabled()
        .background(Color.clear)
    }
}

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.s4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, DSSpacing.s8 + DSSpacing.s4)
            .padding(.vertical, DSSpacing.s4 + DSSpacing.s2)
            .foregroundStyle(isSelected ? Color.foregroundPrimaryWhite : Color.foregroundSecondary)
            .background(chipBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            Capsule().fill(Color.buttonPrimary)
        } else {
            Capsule()
                .fill(Color.buttonSecondary.opacity(0.65))
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

#Preview {
    JobsView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabSelectionViewModel())
}
