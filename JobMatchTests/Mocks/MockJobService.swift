//
//  MockJobService.swift
//  JobMatchTests
//
//  Created by Aleksandra Asichka on 17/05/2026.
//

import Foundation
@testable import MatchFlow

class MockJobService: JobServiceProtocol {
    // State
    var jobs: [Job] = []
    var shouldThrow = false
    
    // Call tracking
    var fetchJobsCalled = false
    var addJobCalled = false
    var addJobFromURLCalled = false
    var lastImportedURL: String?
    var updateStatusCalled = false
    var lastStatus: JobStatus?
    var saveNotesCalled = false
    var lastSavedNotes: String?
    var saveImprovementSuggestionCalled = false
    var lastImprovementSuggestion: String?
    var clearImprovementSuggestionsCalled = false
    
    func fetchJobs(userId: UUID) async throws -> [Job] {
        fetchJobsCalled = true
        if shouldThrow { throw TestError.mock }
        return jobs
    }
    
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?, companyLogoUrl: String?) async throws -> Job {
        addJobCalled = true
        if shouldThrow { throw TestError.mock }
        let job = Job.mock(title: title, company: company, rawText: rawText)
        jobs.append(job)
        return job
    }
    
    func fetchJob(jobId: UUID) async throws -> Job {
        if shouldThrow { throw TestError.mock }
        return jobs.first { $0.id == jobId } ?? Job.mock()
    }
    
    func updateStatus(jobId: UUID, status: JobStatus) async throws {
        updateStatusCalled = true
        lastStatus = status
        if shouldThrow { throw TestError.mock }
    }
    
    func updateMatchScore(jobId: UUID, score: Double) async throws {}
    func updateMatchResults(jobId: UUID, breakdown: MatchBreakdown) async throws {}
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws {}
    func fetchJobText(from urlString: String) async throws -> String { "" }
    func saveAnalysis(jobId: UUID, analysis: JobAnalysis, rawText: String?) async throws {}
    func saveCoverLetter(jobId: UUID, coverLetter: String) async throws {}
    func saveNotes(jobId: UUID, notes: String) async throws {
        saveNotesCalled = true
        lastSavedNotes = notes
        if shouldThrow { throw TestError.mock }
        if let index = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[index].notes = notes
        }
    }

    func saveImprovementSuggestion(jobId: UUID, suggestion: String) async throws {
        saveImprovementSuggestionCalled = true
        lastImprovementSuggestion = suggestion
        if shouldThrow { throw TestError.mock }
        if let index = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[index].improvementSuggestion = suggestion
        }
    }

    func updateCompanyLogoUrl(jobId: UUID, logoUrl: String) async throws {
        if shouldThrow { throw TestError.mock }
        if let index = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[index].companyLogoUrl = logoUrl
        }
    }

    func clearImprovementSuggestions(userId: UUID) async throws {
        clearImprovementSuggestionsCalled = true
        if shouldThrow { throw TestError.mock }
        for index in jobs.indices where jobs[index].userId == userId && jobs[index].status == .exploring {
            jobs[index].improvementSuggestion = nil
        }
    }

    func checkPendingJob() -> (url: String?, text: String?) { (nil, nil) }

    func addJobFromShare(userId: UUID) async throws -> Job? { nil }

    func addJobFromURL(userId: UUID, url: String) async throws -> Job {
        addJobFromURLCalled = true
        lastImportedURL = url
        if shouldThrow { throw TestError.mock }
        let job = Job.mock(rawText: "Imported job description", url: url)
        jobs.append(job)
        return job
    }

    func deleteJob(jobId: UUID) async throws {
        if shouldThrow { throw TestError.mock }
        jobs.removeAll { $0.id == jobId }
    }
}

enum TestError: Error {
    case mock
}
