//
//  JobDetailViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine

@MainActor
class JobDetailViewModel: ObservableObject {
    @Published var selectedStatus: JobStatus = .applied
    @Published var notes: String = ""
    @Published var jobDescription: String = ""
    @Published var analysis: JobAnalysis? = nil
    @Published var isAnalyzing = false
    @Published var errorMessage = ""
    @Published var updatedJob: Job? = nil
    @Published var coverLetter: String? = nil
    @Published var isGeneratingCoverLetter = false
    @Published var showCoverLetter = false

    private var loadedNotes: String = ""

    private let jobService: JobServiceProtocol
    private let resumeService: ResumeServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let aiService: AIServiceProtocol

    init(
        jobService: JobServiceProtocol = JobService(),
        resumeService: ResumeServiceProtocol = ResumeService(),
        profileService: ProfileServiceProtocol = ProfileService(),
        aiService: AIServiceProtocol = AIService()
    ) {
        self.jobService = jobService
        self.resumeService = resumeService
        self.profileService = profileService
        self.aiService = aiService
    }

    func loadOnAppear(job: Job, userId: UUID) async {
        await loadJob(jobId: job.id)

        let currentJob = updatedJob ?? job
        selectedStatus = currentJob.status
        let serverNotes = currentJob.notes ?? ""
        notes = serverNotes
        loadedNotes = serverNotes
        if currentJob.summary == nil {
            await analyze(job: currentJob)
        } else {
            analysis = JobAnalysis(
                title: currentJob.title,
                company: currentJob.company,
                summary: currentJob.summary,
                skills: currentJob.skills,
                difficulty: currentJob.difficulty
            )
        }

        if currentJob.coverLetter == nil {
            await generateCoverLetter(job: currentJob, userId: userId)
        }
    }

    func regenerateCoverLetter(job: Job, userId: UUID) async {
        await generateCoverLetter(job: job, userId: userId)
    }

    func generateCoverLetter(job: Job, userId: UUID) async {
        isGeneratingCoverLetter = true
        do {
            guard let resume = try await resumeService.fetchDefaultResume(userId: userId),
                  let resumeText = resume.rawText else {
                errorMessage = "Please upload a resume first"
                isGeneratingCoverLetter = false
                return
            }
            
            guard let profile = try await profileService.fetchProfile(userId: userId) else {
                errorMessage = "Please complete your profile first"
                isGeneratingCoverLetter = false
                return
            }
            
            let jobText = try await aiService.ensureEnglishJobText(job.rawText ?? job.url ?? "")
            let letter = try await aiService.generateCoverLetter(
                resume: resumeText,
                jobDescription: jobText,
                profile: profile
            )
            
            coverLetter = letter
            try await jobService.saveCoverLetter(jobId: job.id, coverLetter: letter)
        } catch {
            errorMessage = error.localizedDescription
        }
        isGeneratingCoverLetter = false
    }
    
    func updateStatus(job: Job, status: JobStatus) async {
        do {
            try await jobService.updateStatus(jobId: job.id, status: status)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveNotesIfNeeded(job: Job) async {
        guard notes != loadedNotes else { return }
        do {
            try await jobService.saveNotes(jobId: job.id, notes: notes)
            loadedNotes = notes
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func analyze(job: Job) async {
        isAnalyzing = true
        do {
            let text = jobDescription.isEmpty ? (job.rawText ?? "") : jobDescription
            let englishText = try await aiService.ensureEnglishJobText(text)
            let result = try await aiService.analyzeJob(description: englishText)
            analysis = result
            try await jobService.saveAnalysis(jobId: job.id, analysis: result, rawText: nil)
            updatedJob = try await jobService.fetchJob(jobId: job.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isAnalyzing = false
    }
    
    func loadJob(jobId: UUID) async {
        do {
            let fresh = try await jobService.fetchJob(jobId: jobId)
            updatedJob = fresh
        } catch {
            print("❌ load job error: \(error)")
        }
    }
}
