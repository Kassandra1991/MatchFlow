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
    var updateStatusCalled = false
    var lastStatus: JobStatus?
    
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
    func checkPendingJob() -> (url: String?, text: String?) { (nil, nil) }

    func addJobFromShare(userId: UUID) async throws -> Job? { nil }

    func deleteJob(jobId: UUID) async throws {
        if shouldThrow { throw TestError.mock }
        jobs.removeAll { $0.id == jobId }
    }
}

enum TestError: Error {
    case mock
}
