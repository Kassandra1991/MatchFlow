//
//  JobsViewModelTests.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 17/05/2026.
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("JobsViewModel")
struct JobsViewModelTests {
    
    @Test("Fetch jobs populates jobs array")
    func fetchJobsPopulatesArray() async {
        let mockService = MockJobService()
        mockService.jobs = [Job.mock(), Job.mock()]
        let viewModel = await JobsViewModel(jobService: mockService)
        
        await viewModel.fetchJobs(userId: UUID())
        
        let count = await viewModel.jobs.count
        #expect(count == 2)
        #expect(mockService.fetchJobsCalled)
    }
    
    @Test("Fetch jobs sets error on failure")
    func fetchJobsSetsErrorOnFailure() async {
        let mockService = MockJobService()
        mockService.shouldThrow = true
        let viewModel = await JobsViewModel(jobService: mockService)
        
        await viewModel.fetchJobs(userId: UUID())
        
        let error = await viewModel.errorMessage
        #expect(!error.isEmpty)
    }
    
    @Test("Add job manually inserts job at top")
    func addJobManuallyInsertsAtTop() async {
        let mockService = MockJobService()
        mockService.jobs = [Job.mock(title: "Existing Job")]
        let viewModel = await JobsViewModel(jobService: mockService)
        await viewModel.fetchJobs(userId: UUID())
        
        await viewModel.addJobManually(
            userId: UUID(),
            url: "",
            company: "Acme",
            rawText: String(repeating: "a", count: 300)
        )
        
        let jobs = await viewModel.jobs
        #expect(mockService.addJobCalled)
        #expect(jobs.count >= 1)
    }
    
    @Test("Update status calls service")
    func updateStatusCallsService() async {
        let mockService = MockJobService()
        let job = Job.mock(status: .applied)
        mockService.jobs = [job]
        let viewModel = await JobsViewModel(jobService: mockService)
        await viewModel.fetchJobs(userId: UUID())
        
        await viewModel.updateStatus(job: job, status: .interview)
        
        #expect(mockService.updateStatusCalled)
        #expect(mockService.lastStatus == .interview)
    }
    
    @Test("Add job from pasted URL calls service")
    func addJobFromPastedURLCallsService() async {
        let mockService = MockJobService()
        let viewModel = await JobsViewModel(jobService: mockService)
        let url = "https://www.linkedin.com/jobs/view/123456"

        let success = await viewModel.addJobFromPastedURL(userId: UUID(), url: url)

        #expect(success)
        #expect(mockService.addJobFromURLCalled)
        #expect(mockService.lastImportedURL == url)
    }

    @Test("Invalid pasted URL returns false without calling service")
    func invalidPastedURLDoesNothing() async {
        let mockService = MockJobService()
        let viewModel = await JobsViewModel(jobService: mockService)

        let success = await viewModel.addJobFromPastedURL(userId: UUID(), url: "not-a-url")

        #expect(!success)
        #expect(!mockService.addJobFromURLCalled)
        let error = await viewModel.errorMessage
        #expect(error == "Paste a valid job link")
    }

    @Test("No pending job does nothing")
    func noPendingJobDoesNothing() async {
        let mockService = MockJobService()
        let viewModel = await JobsViewModel(jobService: mockService)
        
        await viewModel.addJobFromShare(userId: UUID())
        
        let jobs = await viewModel.jobs
        #expect(jobs.isEmpty)
        #expect(!mockService.addJobCalled)
    }
}
