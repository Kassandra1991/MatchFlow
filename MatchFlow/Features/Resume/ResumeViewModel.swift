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
    
    private let resumeService = ResumeService.shared
    
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
            resumes.insert(resume, at: 0)
            successMessage = "Resume saved!"
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
