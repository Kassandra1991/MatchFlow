//
//  ResumeViewModelTests.swift
//  JobMatchTests
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("ResumeViewModel")
struct ResumeViewModelTests {
    @Test("Saving resume clears exploring improvement suggestions")
    func saveResumeClearsImprovementSuggestions() async {
        let mockJobService = MockJobService()
        let userId = UUID()
        mockJobService.jobs = [
            Job.mock(userId: userId, status: .exploring, improvementSuggestion: "Old tip")
        ]

        let mockResumeService = MockResumeService()
        let viewModel = await ResumeViewModel(
            resumeService: mockResumeService,
            jobService: mockJobService
        )

        await viewModel.saveResume(
            userId: userId,
            title: "CV",
            rawText: "Resume body",
            isDefault: true
        )

        #expect(mockJobService.clearImprovementSuggestionsCalled)
        #expect(mockJobService.jobs[0].improvementSuggestion == nil)
    }
}
