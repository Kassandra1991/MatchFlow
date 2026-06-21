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
    @FocusState private var isNotesFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AuthBackgroundView()

                ScrollView {
                    VStack(spacing: 0) {
                        JobDetailHeaderView(
                            job: job,
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .padding(.bottom, DSSpacing.s48)

                        VStack(spacing: DSSpacing.s24) {
                            if let breakdown = MatchBreakdown.from(job: job) {
                                JobMatchCardView(
                                    job: job,
                                    breakdown: breakdown,
                                    improvementSuggestion: viewModel.improvementSuggestion,
                                    isLoadingImprovement: viewModel.isLoadingImprovement
                                )
                                #if DEBUG
                                .background(JobDetailLayoutProbe(label: "matchCard", hypothesisId: "H-D1"))
                                #endif
                            }

                            if job.status == .exploring {
                                coverLetterSection
                                aboutRoleSection
                            } else {
                                aboutRoleSection
                                coverLetterSection
                            }

                            notesCard
                        }
                    }
                    .padding(.horizontal, DSSpacing.s16)
                    .padding(.bottom, DSSpacing.s32)
                    .frame(minHeight: geometry.size.height, alignment: .top)
                }
                #if DEBUG
                .background(JobDetailLayoutProbe(label: "scrollView", hypothesisId: "H-D2"))
                #endif
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .scrollDismissesKeyboard(.interactively)
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task {
            if let userId = auth.currentUserId {
                await viewModel.loadOnAppear(job: job, userId: userId)
            }
        }
        .onChange(of: viewModel.selectedStatus) {
            isNotesFocused = false
            job.status = viewModel.selectedStatus
            Task {
                await viewModel.updateStatus(job: job, status: viewModel.selectedStatus)
                if let userId = auth.currentUserId {
                    await viewModel.loadOrGenerateImprovement(job: job, userId: userId)
                }
            }
        }
        .onChange(of: viewModel.updatedJob) {
            if let updated = viewModel.updatedJob {
                job = updated
            }
        }
        .onDisappear {
            isNotesFocused = false
            Task { await viewModel.saveNotesIfNeeded(job: job) }
        }
        .alert("Error", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
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
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { !viewModel.errorMessage.isEmpty },
            set: { if !$0 { viewModel.errorMessage = "" } }
        )
    }

    private var analyzingCard: some View {
        HStack(spacing: DSSpacing.s8) {
            ProgressView()
            Text("Analyzing role...")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.s16)
        .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r24))
    }

    private var analyzePromptCard: some View {
        VStack(spacing: DSSpacing.s16) {
            Text("No analysis yet")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)

            if job.rawText == nil || job.rawText == job.url {
                TextEditor(text: $viewModel.jobDescription)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 120)
                    .textStyle(.body1Regular)
                    .overlay(alignment: .topLeading) {
                        if viewModel.jobDescription.isEmpty {
                            Text("Paste job description here...")
                                .textStyle(.body1Regular)
                                .foregroundStyle(Color.foregroundMinor)
                                .padding(DSSpacing.s8)
                        }
                    }
            }

            Button {
                Task { await viewModel.analyze(job: job) }
            } label: {
                Label("Analyze with AI", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.s16)
        .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r24))
    }

    @ViewBuilder
    private var aboutRoleSection: some View {
        if let summary = job.summary, !summary.isEmpty {
            JobAboutRoleCardView(
                summary: summary,
                skills: job.skills,
                url: job.url
            )
        } else if viewModel.isAnalyzing {
            analyzingCard
        } else if viewModel.analysis == nil {
            analyzePromptCard
        }
    }

    private var coverLetterSection: some View {
        JobCoverLetterCardView(
            isGenerating: viewModel.isGeneratingCoverLetter,
            isEnabled: job.coverLetter != nil || viewModel.coverLetter != nil
        ) {
            isNotesFocused = false
            viewModel.showCoverLetter = true
            AnalyticsService.log(.coverLetterOpened)
        }
    }

    private var notesCard: some View {
        NotesEditorView(text: $viewModel.notes, isFocused: $isNotesFocused)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.r24))
    }
}

#Preview {
    NavigationStack {
        JobDetailView(job: Job(
            id: UUID(),
            userId: UUID(),
            url: "https://linkedin.com/jobs/view/123",
            title: "GenAI Engineer / LLM Engineer",
            company: "Figma",
            rawText: "Job description",
            matchScore: 0.59,
            experienceScore: 0.8,
            skillsCoverage: 0.85,
            levelFit: 0.4,
            status: .applied,
            summary: "We are looking for a Senior Engineer to join our team.",
            appliedAt: Date(),
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}

#if DEBUG
private enum JobDetailLayoutDebugLog {
    static let logPath = "/Users/aleksandraasichka/Documents/Developer/match_flow/MatchFlow/.cursor/debug-54a378.log"
    static let sessionId = "54a378"

    static func write(hypothesisId: String, message: String, data: [String: Any], runId: String = "device-margin") {
        let payload: [String: Any] = [
            "sessionId": sessionId,
            "hypothesisId": hypothesisId,
            "location": "JobDetailView.swift",
            "message": message,
            "data": data,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
            "runId": runId
        ]

        if let json = try? JSONSerialization.data(withJSONObject: payload),
           var line = String(data: json, encoding: .utf8) {
            line.append("\n")
            NSLog("[JobDetailLayout] %@", line)
            if let lineData = line.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logPath),
                   let handle = FileHandle(forWritingAtPath: logPath) {
                    handle.seekToEndOfFile()
                    handle.write(lineData)
                    try? handle.close()
                } else {
                    FileManager.default.createFile(atPath: logPath, contents: lineData)
                }
            }
        }
    }
}

private struct JobDetailLayoutProbe: View {
    let label: String
    let hypothesisId: String

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { logFrame(geo) }
                .onChange(of: geo.size) { _, _ in logFrame(geo) }
        }
    }

    private func logFrame(_ geo: GeometryProxy) {
        let global = geo.frame(in: .global)
        let safe = geo.safeAreaInsets
        let screenWidth = UIScreen.main.bounds.width
        JobDetailLayoutDebugLog.write(
            hypothesisId: hypothesisId,
            message: label,
            data: [
                "width": geo.size.width,
                "minX": global.minX,
                "maxX": global.maxX,
                "safeLeading": safe.leading,
                "safeTrailing": safe.trailing,
                "screenWidth": screenWidth,
                "rightGap": screenWidth - global.maxX
            ],
            runId: "device-margin-v3"
        )
    }
}
#endif
