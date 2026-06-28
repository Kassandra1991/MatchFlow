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
            if try await jobService.addJobFromShare(userId: userId) != nil {
                await reloadJobs(userId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addJobManually(userId: UUID, url: String, company: String, rawText: String) async {
        guard AddJobLayout.isDescriptionSufficient(rawText) else { return }

        isLoading = true
        errorMessage = ""
        do {
            let job = try await jobService.addJob(
                userId: userId,
                url: url.isEmpty ? nil : url,
                rawText: rawText,
                title: nil,
                company: company.trimmingCharacters(in: .whitespacesAndNewlines),
                companyLogoUrl: nil
            )
            AnalyticsService.log(.jobAdded(source: "manual"))
            try await jobService.calculateAndSaveMatchScore(job: job, userId: userId)
            await reloadJobs(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @discardableResult
    func addJobFromPastedURL(userId: UUID, url: String) async -> Bool {
        guard let normalizedURL = AddJobImportLayout.normalizedJobURL(url) else {
            errorMessage = AddJobImportLayout.invalidURLError
            return false
        }

        isLoading = true
        errorMessage = ""
        do {
            _ = try await jobService.addJobFromURL(userId: userId, url: normalizedURL)
            AnalyticsService.log(.jobAdded(source: "url_paste"))
            await reloadJobs(userId: userId)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
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

    private func reloadJobs(userId: UUID) async {
        await fetchJobs(userId: userId)
    }
}
