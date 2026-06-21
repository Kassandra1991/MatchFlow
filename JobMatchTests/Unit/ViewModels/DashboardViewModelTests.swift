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

    @Test("Is onboarding when no jobs")
    func isOnboardingWhenEmpty() async {
        let viewModel = await DashboardViewModel()
        let onboarding = await viewModel.isOnboarding
        #expect(onboarding == true)
    }

    @Test("Is not onboarding when jobs exist")
    func isNotOnboardingWhenJobsExist() async {
        let viewModel = await DashboardViewModel()
        await MainActor.run {
            viewModel.allJobs = [Job.mock()]
        }
        let onboarding = await viewModel.isOnboarding
        #expect(onboarding == false)
    }

    @Test("Progress counts return correct values")
    func progressCounts() async {
        let viewModel = await DashboardViewModel()
        await MainActor.run {
            viewModel.allJobs = [
                Job.mock(status: .exploring),
                Job.mock(status: .exploring),
                Job.mock(status: .applied),
                Job.mock(status: .interview),
                Job.mock(status: .rejected),
                Job.mock(status: .offer)
            ]
        }
        let explored = await viewModel.exploredCount
        let applied = await viewModel.appliedCount
        let interviews = await viewModel.interviewCount
        let rejected = await viewModel.rejectedCount
        let offer = await viewModel.offerCount
        #expect(explored == 2)
        #expect(applied == 1)
        #expect(interviews == 1)
        #expect(rejected == 1)
        #expect(offer == 1)
    }

    @Test("JobInsights decodes top matches insight")
    func jobInsightsDecoding() throws {
        let json = """
        {"summary": "Keep improving Python.", "top_matches_insight": "Your top roles align with AI engineering."}
        """
        let data = Data(json.utf8)
        let insights = try JSONDecoder().decode(JobInsights.self, from: data)
        #expect(insights.summary == "Keep improving Python.")
        #expect(insights.topMatchesInsight == "Your top roles align with AI engineering.")
    }

    @Test("JobInsights decodes camelCase topMatchesInsight from AI response")
    func jobInsightsCamelCaseDecoding() throws {
        let json = """
        {"summary": "Keep going.", "topMatchesInsight": "Your profile aligns with AI roles."}
        """
        let data = Data(json.utf8)
        let insights = try JSONDecoder().decode(JobInsights.self, from: data)
        #expect(insights.topMatchesInsight == "Your profile aligns with AI roles.")
    }

    @Test("Hero advice clamps to max characters")
    func heroAdviceClamping() {
        let long = String(repeating: "a", count: 200)
        let clamped = InsightsHeroLayout.clampedAdvice(long)
        #expect(clamped.count <= InsightsHeroLayout.adviceMaxCharacters)
        #expect(InsightsHeroLayout.adviceMaxCharacters == 145)
    }
}
