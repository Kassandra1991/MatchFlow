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
    @State private var showAddManually = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.jobs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No jobs yet")
                            .font(.headline)
                        Text("Share a job from Safari or LinkedIn\nor add manually")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Add Manually") {
                            showAddManually = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(viewModel.jobs) { job in
                        NavigationLink(destination: JobDetailView(job: job)) {
                            JobRowView(job: job)
                        }
                    }
                }
            }
            .navigationTitle("Applications")
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
                        .foregroundColor(.blue)
                    Text("Match: \(Int(score * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: JobStatus
    
    var color: Color {
        switch status {
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
                    Button("Save") {
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
}
