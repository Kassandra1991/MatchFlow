//
//  JobDetailView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI

struct JobDetailView: View {
    @State var job: Job
    @StateObject private var viewModel = JobDetailViewModel()
    @EnvironmentObject private var auth: AuthViewModel
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title ?? "Unknown Role")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(job.company ?? "Unknown Company")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let url = job.url, let link = URL(string: url) {
                        Link("Open Job Posting", destination: link)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
                
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("", selection: $viewModel.selectedStatus) {
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(JobStatusStyle.color(for: status))
                                    .frame(width: 8, height: 8)
                                Text(JobStatusStyle.label(for: status))
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(JobStatusStyle.color(for: viewModel.selectedStatus))
                }
            }
            
            if let breakdown = MatchBreakdown.from(job: job) {
                Section("Match Breakdown") {
                    MatchBreakdownView(breakdown: breakdown)
                }
            }

            Section {
                HStack {
                    Text("AI Analysis")
                        .font(.headline)
                    Spacer()
                    if let score = job.matchScore {
                        MatchScoreBadge(score: score)
                    }
                }
                
                if viewModel.isAnalyzing {
                    HStack {
                        ProgressView()
                        Text("Analyzing...")
                            .foregroundColor(.secondary)
                    }
                } else if let analysis = viewModel.analysis {
                    if let summary = analysis.summary {
                        Text(summary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if !job.skills.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Required Skills")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            FlowLayout(items: job.skills) { skill in
                                SkillTag(name: skill, color: .blue)
                            }
                        }
                    }
                    
                    if let difficulty = analysis.difficulty {
                        HStack {
                            Text("Level")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(difficulty.capitalized)
                                .fontWeight(.medium)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("No analysis yet")
                            .foregroundColor(.secondary)
                        
                        if job.rawText == nil || job.rawText == job.url {
                            TextEditor(text: $viewModel.jobDescription)
                                .frame(minHeight: 120)
                                .overlay(
                                    Group {
                                        if viewModel.jobDescription.isEmpty {
                                            Text("Paste job description here...")
                                                .foregroundColor(.secondary)
                                                .padding(8)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }
                        
                        Button {
                            Task { await viewModel.analyze(job: job) }
                        } label: {
                            Label("Analyze with AI", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            
            Section {
                Button {
                    viewModel.showCoverLetter = true
                    AnalyticsService.log(.coverLetterOpened)
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("Cover Letter")
                            .foregroundColor(.primary)
                        Spacer()
                        if viewModel.isGeneratingCoverLetter {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .disabled(viewModel.isGeneratingCoverLetter || (job.coverLetter == nil && viewModel.coverLetter == nil))
            }
            .sheet(isPresented: $viewModel.showCoverLetter) {
                CoverLetterView(
                    coverLetter: viewModel.coverLetter ?? job.coverLetter ?? "",
                    onRegenerate: {
                        Task {
                            if let userId = auth.currentUserId {
                                await viewModel.regenerateCoverLetter(job: job, userId: userId)
                            }
                        }
                    }
                )
            }
            
            Section("Notes") {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
                    .overlay(
                        Group {
                            if viewModel.notes.isEmpty {
                                Text("Add notes...")
                                    .foregroundColor(.secondary)
                                    .padding(4)
                            }
                        },
                        alignment: .topLeading
                    )
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Job Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .task {
            if let userId = auth.currentUserId {
                await viewModel.loadOnAppear(job: job, userId: userId)
            }
        }
        .onChange(of: viewModel.selectedStatus) {
            Task { await viewModel.updateStatus(job: job, status: viewModel.selectedStatus) }
        }
        .onChange(of: viewModel.updatedJob) {
            if let updated = viewModel.updatedJob {
                job = updated
            }
        }
    }
}

#Preview {
    NavigationView {
        JobDetailView(job: Job(
            id: UUID(),
            userId: UUID(),
            url: "https://linkedin.com",
            title: "iOS Developer",
            company: "Apple",
            rawText: "Job description",
            matchScore: 0.85,
            status: .applied,
            appliedAt: Date(),
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
