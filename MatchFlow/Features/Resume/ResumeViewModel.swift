//
//  ResumeViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine

@MainActor
class ResumeViewModel: ObservableObject {
    @Published var resumes: [Resume] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    
    private let resumeService: ResumeServiceProtocol
    private let jobService: JobServiceProtocol

    init(
        resumeService: ResumeServiceProtocol = ResumeService(),
        jobService: JobServiceProtocol = JobService()
    ) {
        self.resumeService = resumeService
        self.jobService = jobService
    }
    
    func fetchResumes(userId: UUID) async {
        isLoading = true
        do {
            resumes = try await resumeService.fetchResumes(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func saveResume(userId: UUID, title: String, rawText: String, isDefault: Bool) async {
        isLoading = true
        errorMessage = ""
        do {
            let resume = try await resumeService.saveResume(
                userId: userId,
                title: title,
                rawText: rawText,
                isDefault: isDefault
            )
            resumes = [resume]
            successMessage = "Resume saved!"
            try? await jobService.clearImprovementSuggestions(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func extractTextFromPDF(url: URL) -> String {
        resumeService.extractTextFromPDF(url: url)
    }
    
    func setDefault(resume: Resume, userId: UUID) async {
        do {
            try await resumeService.setDefault(resumeId: resume.id, userId: userId)
            for i in resumes.indices {
                resumes[i].isDefault = resumes[i].id == resume.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteResume(resume: Resume) async {
        do {
            try await resumeService.deleteResume(resumeId: resume.id)
            resumes.removeAll { $0.id == resume.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
