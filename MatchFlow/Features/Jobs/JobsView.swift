//
//  JobsView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI
import Supabase
import Auth

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
                // MARK: - Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", count: viewModel.jobs.count, isSelected: tabSelection.jobsFilter == nil, color: .primary) {
                            tabSelection.jobsFilter = nil
                        }
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            let count = viewModel.jobs.filter { $0.status == status }.count
                            FilterChip(
                                title: status.rawValue.capitalized,
                                count: count,
                                isSelected: tabSelection.jobsFilter == status,
                                color: statusColor(status)
                            ) {
                                tabSelection.jobsFilter = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                // MARK: - List
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
                AddJobView(viewModel: viewModel)
            }
            .task {
                if let userId = await getCurrentUserId() {
                    await viewModel.fetchJobs(userId: userId)
                    await viewModel.addJobFromShare(userId: userId)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    if let userId = try? await supabase.auth.session.user.id,
                       let uuid = UUID(uuidString: userId.uuidString) {
                        await viewModel.addJobFromShare(userId: uuid)
                        await viewModel.fetchJobs(userId: uuid)
                    }
                }
            }
        }
    }
    
    private func getCurrentUserId() async -> UUID? {
        guard let session = try? await supabase.auth.session else { return nil }
        return UUID(uuidString: session.user.id.uuidString)
    }
    
    private func statusColor(_ status: JobStatus) -> Color {
        switch status {
        case .exploring: return .gray
        case .applied: return .blue
        case .interview: return .orange
        case .rejected: return .red
        case .offer: return .green
        }
    }
}

// MARK: - Filter Chip
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

struct JobRowView: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(job.title ?? "Unknown Role")
                    .font(.headline)
                Spacer()
                StatusBadge(status: job.status)
            }
            Text(job.company ?? "Unknown Company")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let score = job.matchScore {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(matchColor(score))
                    Text("Match: \(Int(score * 100))%")
                        .font(.caption)
                        .foregroundColor(matchColor(score))
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func matchColor(_ score: Double) -> Color {
        switch score {
        case 0.55...: return .green
        case 0.45..<0.55: return .orange
        default: return .red
        }
    }
}

struct StatusBadge: View {
    let status: JobStatus
    
    var color: Color {
        switch status {
        case .exploring: return .gray
        case .applied: return .blue
        case .interview: return .orange
        case .rejected: return .red
        case .offer: return .green
        }
    }
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

struct AddJobView: View {
    @ObservedObject var viewModel: JobsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""
    @State private var rawText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Job URL (optional)") {
                    TextField("https://linkedin.com/jobs/...", text: $url)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                Section("Job Description") {
                    TextEditor(text: $rawText)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            if let userId = try? await supabase.auth.session.user.id,
                               let uuid = UUID(uuidString: userId.uuidString) {
                                await viewModel.addJobManually(
                                    userId: uuid,
                                    url: url,
                                    rawText: rawText
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(rawText.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    JobsView()
        .environmentObject(AuthViewModel())
        .environmentObject(TabSelectionViewModel())
}
