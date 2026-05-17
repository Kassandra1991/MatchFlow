//
//  DashboardViewModelTests.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 17/05/2026.
//

import Foundation
import Testing
@testable import MatchFlow

@Suite("DashboardViewModel")
struct DashboardViewModelTests {
    
    @Test("Jobs this week returns correct count")
    func jobsThisWeekCount() async {
        let viewModel = await DashboardViewModel()
        let recentJob = Job.mock(createdAt: Date())
        let oldJob = Job.mock(createdAt: Date().addingTimeInterval(-8 * 24 * 60 * 60))
        await MainActor.run {
            viewModel.allJobs = [recentJob, oldJob]
        }
        let count = await viewModel.jobsThisWeek
        #expect(count == 1)
    }
    
    @Test("Top matches returns jobs sorted by score descending")
    func topMatchesSortedByScore() async {
        let viewModel = await DashboardViewModel()
        let lowMatch = Job.mock(matchScore: 0.3)
        let highMatch = Job.mock(matchScore: 0.8)
        let midMatch = Job.mock(matchScore: 0.5)
        await MainActor.run {
            viewModel.allJobs = [lowMatch, highMatch, midMatch]
        }
        let top = await viewModel.topMatches
        #expect(top.first?.matchScore == 0.8)
    }
    
    @Test("Jobs for status filters correctly")
    func jobsForStatus() async {
        let viewModel = await DashboardViewModel()
        await MainActor.run {
            viewModel.allJobs = [
                Job.mock(status: .applied),
                Job.mock(status: .applied),
                Job.mock(status: .interview)
            ]
        }
        let applied = await viewModel.jobs(for: .applied)
        let interview = await viewModel.jobs(for: .interview)
        let rejected = await viewModel.jobs(for: .rejected)
        #expect(applied.count == 2)
        #expect(interview.count == 1)
        #expect(rejected.count == 0)
    }
    
    @Test("Empty jobs returns zero this week")
    func emptyJobsThisWeek() async {
        let viewModel = await DashboardViewModel()
        let count = await viewModel.jobsThisWeek
        #expect(count == 0)
    }
    
    @Test("Top matches limited to 5")
    func topMatchesLimitedToFive() async {
        let viewModel = await DashboardViewModel()
        await MainActor.run {
            viewModel.allJobs = (0..<10).map { i in
                Job.mock(matchScore: Double(i) / 10)
            }
        }
        let top = await viewModel.topMatches
        #expect(top.count == 5)
    }
}
