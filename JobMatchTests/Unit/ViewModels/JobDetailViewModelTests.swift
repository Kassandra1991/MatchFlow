//
//  JobDetailViewModelTests.swift
//  JobMatchTests
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("JobDetailViewModel")
struct JobDetailViewModelTests {
    @Test("Load on appear builds analysis from existing summary")
    func loadOnAppearBuildsAnalysisFromSummary() async {
        let mockJobService = MockJobService()
        let job = Job.mock(summary: "Existing summary", skills: ["Swift"])
        mockJobService.jobs = [job]
        let viewModel = await JobDetailViewModel(jobService: mockJobService)
        let userId = UUID()

        await viewModel.loadOnAppear(job: job, userId: userId)

        let analysis = await viewModel.analysis
        #expect(analysis?.summary == "Existing summary")
    }

    @Test("Load on appear loads fresh job data")
    func loadOnAppearLoadsFreshJob() async {
        let mockJobService = MockJobService()
        let job = Job.mock(summary: "Summary")
        mockJobService.jobs = [job]
        let viewModel = await JobDetailViewModel(jobService: mockJobService)

        await viewModel.loadOnAppear(job: job, userId: UUID())

        let updatedJob = await viewModel.updatedJob
        #expect(updatedJob?.id == job.id)
    }
}
