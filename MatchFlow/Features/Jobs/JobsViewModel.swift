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
        let pending = jobService.checkPendingJob()
        guard let url = pending.url ?? pending.text else { return }
        
        isLoading = true
        do {
            var rawText = url
            var title: String? = nil
            var company: String? = nil
            var companyLogoUrl: String? = nil

            if url.contains("linkedin.com/jobs/view") {
                let jobData = try await AIService().fetchJobFromURL(url)
                rawText = jobData.description ?? url
                title = jobData.title
                company = jobData.company
                companyLogoUrl = jobData.companyLogo
            } else if url.hasPrefix("http") {
                rawText = (try? await jobService.fetchJobText(from: url)) ?? url
            }

            let job = try await jobService.addJob(
                userId: userId,
                url: url.hasPrefix("http") ? url : nil,
                rawText: rawText,
                title: title,
                company: company,
                companyLogoUrl: companyLogoUrl
            )
            jobs.insert(job, at: 0)
            try await jobService.calculateAndSaveMatchScore(job: job, userId: userId)
            await fetchJobs(userId: userId)
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
                try await JobService().deleteJob(jobId: job.id)
                jobs.removeAll { $0.id == job.id }
                AnalyticsService.log(.jobDeleted)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
