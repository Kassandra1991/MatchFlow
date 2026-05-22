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
    @State var job: Job
    @StateObject private var viewModel = JobDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // MARK: - Header
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
                                    .fill(statusColor(status))
                                    .frame(width: 8, height: 8)
                                Text(status.rawValue.capitalized)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(statusColor(viewModel.selectedStatus))
                }
            }
            
            // MARK: - AI Analysis
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
            
            // MARK: - Cover Letter
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
                            if let session = try? await supabase.auth.session,
                               let uuid = UUID(uuidString: session.user.id.uuidString) {
                                await viewModel.generateCoverLetter(job: job, userId: uuid)
                            }
                        }
                    }
                )
            }
            
            // MARK: - Notes
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
        .onAppear {
            viewModel.selectedStatus = job.status
            viewModel.notes = job.notes ?? ""
            
            Task {
                // Загружаем свежие данные
                await viewModel.loadJob(jobId: job.id)
                
                // Анализ только если нет summary
                if job.summary == nil {
                    await viewModel.analyze(job: job)
                } else {
                    viewModel.analysis = JobAnalysis(
                        title: job.title,
                        company: job.company,
                        summary: job.summary,
                        skills: job.skills,
                        difficulty: job.difficulty
                    )
                }
                
                // Генерируем cover letter в фоне но не показываем автоматически
                if job.coverLetter == nil {
                    Task {
                        if let session = try? await supabase.auth.session,
                           let uuid = UUID(uuidString: session.user.id.uuidString) {
                            await viewModel.generateCoverLetter(job: job, userId: uuid)
                        }
                    }
                }
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

// MARK: - Match Score Badge
struct MatchScoreBadge: View {
    let score: Double
    
    var color: Color {
        switch score {
        case 0.55...: return .green
        case 0.45..<0.55: return .orange
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
        TagFlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

struct TagFlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width && rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
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
