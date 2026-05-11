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
            allJobs = try await JobService.shared.fetchJobs(userId: userId)
        } catch {
            print("❌ Dashboard load error: \(error)")
        }
        isLoading = false
        
        // Генерируем инсайты после загрузки
        await generateInsights()
    }
    
    func generateInsights() async {
        guard !allJobs.isEmpty else { return }
        isLoadingInsights = true
        do {
            let raw = try await AIService.shared.generateInsights(jobs: allJobs)
            if let data = raw.data(using: .utf8) {
                insights = try JSONDecoder().decode(JobInsights.self, from: data)
            }
        } catch {
            print("❌ Insights error: \(error)")
        }
        isLoadingInsights = false
    }
}
