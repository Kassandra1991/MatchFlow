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

    @Test("Load on appear syncs notes from server")
    func loadOnAppearSyncsNotesFromServer() async {
        let mockJobService = MockJobService()
        let jobId = UUID()
        let staleJob = Job.mock(id: jobId, summary: "Summary", coverLetter: "Letter", notes: nil)
        let freshJob = Job.mock(id: jobId, summary: "Summary", coverLetter: "Letter", notes: "Server notes")
        mockJobService.jobs = [freshJob]
        let viewModel = await JobDetailViewModel(jobService: mockJobService)

        await viewModel.loadOnAppear(job: staleJob, userId: UUID())

        let notes = await viewModel.notes
        #expect(notes == "Server notes")
    }

    @Test("Save notes when changed")
    func saveNotesWhenChanged() async {
        let mockJobService = MockJobService()
        let job = Job.mock(summary: "Summary", coverLetter: "Letter", notes: "Initial")
        mockJobService.jobs = [job]
        let viewModel = await JobDetailViewModel(jobService: mockJobService)
        await viewModel.loadOnAppear(job: job, userId: UUID())

        await MainActor.run { viewModel.notes = "Updated notes" }
        await viewModel.saveNotesIfNeeded(job: job)

        #expect(mockJobService.saveNotesCalled)
        #expect(mockJobService.lastSavedNotes == "Updated notes")
        #expect(mockJobService.jobs[0].notes == "Updated notes")
    }

    @Test("Skip save notes when unchanged")
    func skipSaveNotesWhenUnchanged() async {
        let mockJobService = MockJobService()
        let job = Job.mock(summary: "Summary", coverLetter: "Letter", notes: "Initial")
        mockJobService.jobs = [job]
        let viewModel = await JobDetailViewModel(jobService: mockJobService)
        await viewModel.loadOnAppear(job: job, userId: UUID())

        await viewModel.saveNotesIfNeeded(job: job)

        #expect(!mockJobService.saveNotesCalled)
    }
}
