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
    
    private let jobService = JobService.shared
    
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
        guard let text = pending.text ?? pending.url else { return }
        
        isLoading = true
        do {
            let job = try await jobService.addJob(
                userId: userId,
                url: pending.url,
                rawText: text,
                title: nil,
                company: nil
            )
            jobs.insert(job, at: 0)
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
                company: nil
            )
            jobs.insert(job, at: 0)
            
            // Считаем match score
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
}
