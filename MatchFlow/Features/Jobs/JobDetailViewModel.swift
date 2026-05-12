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

    func generateCoverLetter(job: Job, userId: UUID) async {
        isGeneratingCoverLetter = true
        do {
            // Берём дефолтное резюме
            guard let resume = try await ResumeService.shared.fetchDefaultResume(userId: userId),
                  let resumeText = resume.rawText else {
                errorMessage = "Please upload a resume first"
                isGeneratingCoverLetter = false
                return
            }
            
            // Берём профиль
            guard let profile = try await ProfileService.shared.fetchProfile(userId: userId) else {
                errorMessage = "Please complete your profile first"
                isGeneratingCoverLetter = false
                return
            }
            
            let jobText = job.rawText ?? job.url ?? ""
            let letter = try await AIService.shared.generateCoverLetter(
                resume: resumeText,
                jobDescription: jobText,
                profile: profile
            )
            
            coverLetter = letter
            try await JobService.shared.saveCoverLetter(jobId: job.id, coverLetter: letter)
            showCoverLetter = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isGeneratingCoverLetter = false
    }
    
    func updateStatus(job: Job, status: JobStatus) async {
        do {
            try await JobService.shared.updateStatus(jobId: job.id, status: status)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func analyze(job: Job) async {
        isAnalyzing = true
        do {
            let text = jobDescription.isEmpty ? (job.rawText ?? "") : jobDescription
            let result = try await AIService.shared.analyzeJob(description: text)
            analysis = result
            try await JobService.shared.saveAnalysis(jobId: job.id, analysis: result)
            // Перезагружаем job из базы
            updatedJob = try await JobService.shared.fetchJob(jobId: job.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isAnalyzing = false
    }
    
    func loadJob(jobId: UUID) async {
        do {
            let fresh = try await JobService.shared.fetchJob(jobId: jobId)
            updatedJob = fresh
        } catch {
            print("❌ load job error: \(error)")
        }
    }
}
