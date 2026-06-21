//
//  DashboardViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var allJobs: [Job] = []
    @Published var isLoadingInsights = false
    @Published var insights: JobInsights? = nil

    private let jobService: JobServiceProtocol
    private let aiService: AIServiceProtocol

    init(
        jobService: JobServiceProtocol = JobService(),
        aiService: AIServiceProtocol = AIService()
    ) {
        self.jobService = jobService
        self.aiService = aiService
    }

    var topMatches: [Job] {
        allJobs
            .filter { $0.matchScore != nil }
            .sorted { ($0.matchScore ?? 0) > ($1.matchScore ?? 0) }
            .prefix(5)
            .map { $0 }
    }

    var isOnboarding: Bool { allJobs.isEmpty }

    var exploredCount: Int { jobs(for: .exploring).count }
    var appliedCount: Int { jobs(for: .applied).count }
    var interviewCount: Int { jobs(for: .interview).count }
    var rejectedCount: Int { jobs(for: .rejected).count }
    var offerCount: Int { jobs(for: .offer).count }

    func jobs(for status: JobStatus) -> [Job] {
        allJobs.filter { $0.status == status }
    }

    func load(userId: UUID) async {
        do {
            allJobs = try await jobService.fetchJobs(userId: userId)
        } catch {
            print("❌ Dashboard load error: \(error)")
        }

        await generateInsights()
    }

    func generateInsights() async {
        guard !allJobs.isEmpty else { return }
        isLoadingInsights = true
        do {
            insights = try await aiService.generateInsights(jobs: allJobs)
        } catch {
            print("❌ Insights error: \(error)")
        }
        isLoadingInsights = false
    }
}
