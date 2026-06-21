//
//  MockAIService.swift
//  JobMatchTests
//

import Foundation
@testable import MatchFlow

final class MockAIService: AIServiceProtocol {
    var generateMatchImprovementCalled = false
    var improvementResult = "Increase your match by up to 18% by adding stakeholder management examples."

    func isPrimarilyEnglish(_ text: String) -> Bool { true }

    func ensureEnglishJobText(_ text: String) async throws -> String { text }

    func getEmbedding(for text: String) async throws -> [Float] { [] }

    func analyzeJob(description: String) async throws -> JobAnalysis {
        JobAnalysis(title: nil, company: nil, summary: nil, skills: nil, difficulty: nil)
    }

    func extractResumeProfile(from text: String) async throws -> ResumeProfile {
        ResumeProfile(skills: [], yearsExperience: nil, seniority: nil)
    }

    func calculateMatchScore(resumeEmbedding: [Float], jobEmbedding: [Float]) -> Double { 0 }

    func calculateSkillOverlap(resumeSkills: [String], jobSkills: [String]) -> Double { 0 }

    func matchedJobSkills(resumeSkills: [String], jobSkills: [String]) -> [String] {
        resumeSkills.filter { resumeSkill in
            jobSkills.contains { $0.caseInsensitiveCompare(resumeSkill) == .orderedSame }
        }
    }

    func calculateSeniorityFit(resumeSeniority: String?, resumeYears: Int?, jobDifficulty: String?) -> Double { 0.5 }

    func calculateHybridScore(embeddingScore: Double, skillOverlap: Double, seniorityFit: Double, hasJobSkills: Bool) -> Double {
        embeddingScore
    }

    func buildMatchBreakdown(
        embeddingScore: Double,
        skillOverlap: Double,
        seniorityFit: Double,
        hasJobSkills: Bool,
        matchedSkillsCount: Int,
        totalJobSkillsCount: Int
    ) -> MatchBreakdown {
        MatchBreakdown(
            overallScore: embeddingScore,
            experienceScore: embeddingScore,
            skillsCoverage: skillOverlap,
            levelFit: seniorityFit,
            matchedSkillsCount: matchedSkillsCount,
            totalJobSkillsCount: totalJobSkillsCount
        )
    }

    func generateInsights(jobs: [Job]) async throws -> JobInsights {
        JobInsights(summary: nil)
    }

    func generateCoverLetter(resume: String, jobDescription: String, profile: UserProfile) async throws -> String {
        "Cover letter"
    }

    func generateMatchImprovement(
        job: Job,
        resume: Resume,
        breakdown: MatchBreakdown,
        missingSkills: [String]
    ) async throws -> String {
        generateMatchImprovementCalled = true
        return improvementResult
    }

    func fetchJobFromURL(_ url: String) async throws -> (title: String?, company: String?, location: String?, description: String?, companyLogo: String?) {
        (nil, nil, nil, nil, nil)
    }
}
