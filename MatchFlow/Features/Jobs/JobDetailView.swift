//
//  JobDetailView.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import SwiftUI
import Auth
import Supabase

struct JobDetailView: View {
    let job: Job
    @StateObject private var viewModel = JobDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title ?? "Unknown Role")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(job.company ?? "Unknown Company")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        StatusBadge(status: job.status)
                        Spacer()
                        if let score = job.matchScore {
                            MatchScoreBadge(score: score)
                        }
                    }
                    
                    if let url = job.url, let link = URL(string: url) {
                        Link("Open Job Posting", destination: link)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 8)
                
                // MARK: - Status Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status")
                        .font(.headline)
                    Picker("Status", selection: $viewModel.selectedStatus) {
                        ForEach(JobStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 8)
                
                // MARK: - AI Analysis
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Analysis")
                        .font(.headline)
                    
                    if viewModel.isAnalyzing {
                        HStack {
                            ProgressView()
                            Text("Analyzing...")
                                .foregroundColor(.secondary)
                        }
                    } else if let analysis = viewModel.analysis {
                        // Summary
                        if let summary = analysis.summary {
                            Text(summary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Skills
                        if let skills = analysis.skills, !skills.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Required Skills")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                FlowLayout(items: skills) { skill in
                                    SkillTag(name: skill, color: .blue)
                                }
                            }
                        }
                        
                        // Difficulty
                        if let difficulty = analysis.difficulty {
                            HStack {
                                Text("Level:")
                                    .font(.subheadline)
                                Text(difficulty.capitalized)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    } else {
                        // No analysis yet
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
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                            }
                            
                            Button {
                                Task { await viewModel.analyze(job: job) }
                            } label: {
                                Label("Analyze with AI", systemImage: "sparkles")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.jobDescription.isEmpty && (job.rawText == nil || job.rawText == job.url))
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 8)
                
                // MARK: - Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if viewModel.notes.isEmpty {
                                    Text("Add notes...")
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                }
                            },
                            alignment: .topLeading
                        )
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Job Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.selectedStatus = job.status
            viewModel.notes = job.notes ?? ""
            
            if let summary = job.summary {
                // Есть сохранённый анализ — загружаем
                viewModel.analysis = JobAnalysis(
                    title: job.title,
                    company: job.company,
                    summary: summary,
                    skills: job.skills,
                    difficulty: job.difficulty
                )
            } else {
                // Нет анализа — запускаем автоматически
                Task { await viewModel.analyze(job: job) }
            }
        }
        .onChange(of: viewModel.selectedStatus) {
            Task { await viewModel.updateStatus(job: job, status: viewModel.selectedStatus) }
        }
    }
}

// MARK: - Match Score Badge
struct MatchScoreBadge: View {
    let score: Double
    
    var color: Color {
        switch score {
        case 0.8...: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Text("\(Int(score * 100))% Match")
            .font(.subheadline)
            .fontWeight(.bold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

// MARK: - Skill Tag
struct SkillTag: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

// MARK: - Flow Layout
struct FlowLayout: View {
    let items: [String]
    let content: (String) -> SkillTag
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading) {
            ForEach(items, id: \.self) { item in
                content(item)
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
    }
}
