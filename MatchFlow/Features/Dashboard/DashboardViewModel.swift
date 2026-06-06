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
    @Published var isLoading = false
    @Published var isLoadingInsights = false
    @Published var insights: JobInsights? = nil
    @Published var errorMessage = ""

    private let jobService: JobServiceProtocol
    private let aiService: AIServiceProtocol

    init(
        jobService: JobServiceProtocol = JobService(),
        aiService: AIServiceProtocol = AIService()
    ) {
        self.jobService = jobService
        self.aiService = aiService
    }
    
    var totalJobs: Int { allJobs.count }
    
    var jobsThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allJobs.filter { $0.createdAt > weekAgo }.count
    }
    
    var topMatches: [Job] {
        allJobs
            .filter { $0.matchScore != nil }
            .sorted { ($0.matchScore ?? 0) > ($1.matchScore ?? 0) }
            .prefix(5)
            .map { $0 }
    }
    
    func jobs(for status: JobStatus) -> [Job] {
        allJobs.filter { $0.status == status }
    }
    
    func load(userId: UUID) async {
        isLoading = true
        do {
            allJobs = try await jobService.fetchJobs(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Dashboard load error: \(error)")
        }
        isLoading = false
        
        await generateInsights()
    }
    
    func generateInsights() async {
        guard !allJobs.isEmpty else { return }
        isLoadingInsights = true
        do {
            insights = try await aiService.generateInsights(jobs: allJobs)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Insights error: \(error)")
        }
        isLoadingInsights = false
    }
}
