//
//  JobsViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine

@MainActor
class JobsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAddJob = false
    
    private let jobService: JobServiceProtocol
    
    init(jobService: JobServiceProtocol = JobService()) {
        self.jobService = jobService
    }
    
    func load(userId: UUID?) async {
        guard let userId else { return }
        await fetchJobs(userId: userId)
        await addJobFromShare(userId: userId)
    }

    func fetchJobs(userId: UUID) async {
        isLoading = true
        do {
            jobs = try await jobService.fetchJobs(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func addJobFromShare(userId: UUID) async {
        isLoading = true
        do {
            if let job = try await jobService.addJobFromShare(userId: userId) {
                jobs.insert(job, at: 0)
                await fetchJobs(userId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func addJobManually(userId: UUID, url: String, rawText: String) async {
        isLoading = true
        do {
            let job = try await jobService.addJob(
                userId: userId,
                url: url.isEmpty ? nil : url,
                rawText: rawText,
                title: nil,
                company: nil,
                companyLogoUrl: nil
            )
            jobs.insert(job, at: 0)
            AnalyticsService.log(.jobAdded(source: "manual"))
            try await jobService.calculateAndSaveMatchScore(job: job, userId: userId)
            await fetchJobs(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func updateStatus(job: Job, status: JobStatus) async {
        do {
            try await jobService.updateStatus(jobId: job.id, status: status)
            if let index = jobs.firstIndex(where: { $0.id == job.id }) {
                jobs[index].status = status
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteJobs(at indexSet: IndexSet, from filteredJobs: [Job]) async {
        for index in indexSet {
            let job = filteredJobs[index]
            do {
                try await jobService.deleteJob(jobId: job.id)
                jobs.removeAll { $0.id == job.id }
                AnalyticsService.log(.jobDeleted)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
