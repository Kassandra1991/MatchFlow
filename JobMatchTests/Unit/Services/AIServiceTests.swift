//
//  AIServiceTests.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 17/05/2026.
//

import Testing
@testable import MatchFlow

@Suite("AIService")
struct AIServiceTests {
    
    let service = AIService()
    
    @Test("Ukrainian job text is not primarily English")
    func ukrainianTextIsNotEnglish() {
        #expect(!service.isPrimarilyEnglish("Шукаємо iOS розробника"))
    }

    @Test("English job text is primarily English")
    func englishTextIsEnglish() {
        #expect(service.isPrimarilyEnglish("Senior iOS Developer with SwiftUI"))
    }

    @Test("Empty text is treated as English")
    func emptyTextIsEnglish() {
        #expect(service.isPrimarilyEnglish(""))
        #expect(service.isPrimarilyEnglish("   "))
    }

    @Test("Cosine similarity of identical vectors returns 1")
    func cosineSimilarityIdentical() {
        let vector: [Float] = [1.0, 0.0, 0.0]
        let score = service.calculateMatchScore(
            resumeEmbedding: vector,
            jobEmbedding: vector
        )
        #expect(score == 1.0)
    }
    
    @Test("Cosine similarity of opposite vectors returns -1")
    func cosineSimilarityOpposite() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [-1.0, 0.0]
        )
        #expect(score == -1.0)
    }
    
    @Test("Cosine similarity with empty vectors returns 0")
    func cosineSimilarityEmpty() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [],
            jobEmbedding: []
        )
        #expect(score == 0.0)
    }
    
    @Test("Cosine similarity with mismatched vector sizes returns 0")
    func cosineSimilarityMismatch() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [1.0, 0.0, 0.0]
        )
        #expect(score == 0.0)
    }
    
    @Test("Cosine similarity of orthogonal vectors returns 0")
    func cosineSimilarityOrthogonal() {
        let score = service.calculateMatchScore(
            resumeEmbedding: [1.0, 0.0],
            jobEmbedding: [0.0, 1.0]
        )
        #expect(abs(score) < 0.0001)
    }

    @Test("Skill overlap exact match returns 1")
    func skillOverlapExactMatch() {
        let overlap = service.calculateSkillOverlap(
            resumeSkills: ["Swift"],
            jobSkills: ["Swift"]
        )
        #expect(overlap == 1.0)
    }

    @Test("Skill overlap fuzzy match Swift and SwiftUI")
    func skillOverlapFuzzySwift() {
        let overlap = service.calculateSkillOverlap(
            resumeSkills: ["SwiftUI"],
            jobSkills: ["Swift"]
        )
        #expect(overlap == 1.0)
    }

    @Test("Skill overlap does not fuzzy match generic REST token")
    func skillOverlapGenericRESTNoFuzzy() {
        let overlap = service.calculateSkillOverlap(
            resumeSkills: ["REST API"],
            jobSkills: ["REST"]
        )
        #expect(overlap == 0.0)
    }

    @Test("Skill overlap design job matches design resume synonyms")
    func skillOverlapDesignRole() {
        let jobSkills = [
            "AI", "product design", "UX", "AI design tools",
            "information architecture", "design systems", "prototyping", "user experience"
        ]
        let resumeSkills = [
            "UX/UI Design", "Design Systems", "Prototyping", "Information Architecture",
            "Figma", "AI Tools", "Visual Design"
        ]
        let overlap = service.calculateSkillOverlap(resumeSkills: resumeSkills, jobSkills: jobSkills)
        #expect(overlap >= 0.5)
    }

    @Test("Skill overlap no match returns 0")
    func skillOverlapNoMatch() {
        let overlap = service.calculateSkillOverlap(
            resumeSkills: ["Python"],
            jobSkills: ["Kubernetes"]
        )
        #expect(overlap == 0.0)
    }

    // Scoring contract baseline (bcd613d, skills-first scoring):
    // - missing resume seniority/years returns neutral 0.5 (was 1.0 in 7dcba9b)
    // - hybrid thresholds are lower; weak overlap caps score despite strong embedding
    // Keep expectations aligned with AIService.calculateSeniorityFit / calculateHybridScore.
    // Do not change assertions to match refactors without an explicit contract change.

    @Test("Seniority fit mid candidate on senior job")
    func seniorityFitMidOnSenior() {
        let fit = service.calculateSeniorityFit(
            resumeSeniority: "mid",
            resumeYears: 3,
            jobDifficulty: "senior"
        )
        #expect(abs(fit - 0.6375) < 0.0001)
    }

    @Test("Seniority fit returns neutral 0.5 when data missing")
    func seniorityFitMissingData() {
        let fit = service.calculateSeniorityFit(
            resumeSeniority: nil,
            resumeYears: nil,
            jobDifficulty: "senior"
        )
        #expect(fit == 0.5)
    }

    @Test("Seniority fit junior on senior job is low")
    func seniorityFitJuniorOnSenior() {
        let fit = service.calculateSeniorityFit(
            resumeSeniority: "junior",
            resumeYears: 1,
            jobDifficulty: "senior"
        )
        #expect(fit == 0.40)
    }

    @Test("Hybrid score calibrates strong mid match above 61 percent")
    func hybridScoreCalibratedStrongMatch() {
        let score = service.calculateHybridScore(
            embeddingScore: 0.65,
            skillOverlap: 0.40,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        #expect(score > 0.61)
        #expect(score < 0.95)
    }

    @Test("Hybrid score irrelevant stack stays below 30 percent")
    func hybridScoreIrrelevantStackBelow30() {
        let score = service.calculateHybridScore(
            embeddingScore: 0.50,
            skillOverlap: 0.0,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        #expect(score < 0.30)
    }

    @Test("Hybrid score ignores seniority bonus when skills do not overlap")
    func hybridScoreSeniorityIgnoredWhenNoOverlap() {
        let withoutSeniorityBoost = service.calculateHybridScore(
            embeddingScore: 0.50,
            skillOverlap: 0.0,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        let withOverlap = service.calculateHybridScore(
            embeddingScore: 0.50,
            skillOverlap: 0.40,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        #expect(withOverlap > withoutSeniorityBoost + 0.15)
    }

    @Test("Hybrid score penalizes low overlap when embedding is weak")
    func hybridScoreLowOverlapPenalty() {
        let score = service.calculateHybridScore(
            embeddingScore: 0.50,
            skillOverlap: 0.15,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        #expect(score < 0.30)
    }

    @Test("Hybrid score stays low when overlap weak despite strong embedding")
    func hybridScoreLowOverlapDespiteEmbedding() {
        let score = service.calculateHybridScore(
            embeddingScore: 0.62,
            skillOverlap: 0.20,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        #expect(score < 0.35)
    }

    @Test("Match score tier thresholds")
    func matchScoreTierThresholds() {
        #expect(MatchScoreTier(score: 0.29) == .low)
        #expect(MatchScoreTier(score: 0.30) == .medium)
        #expect(MatchScoreTier(score: 0.61) == .high)
        #expect(MatchScoreTier(score: 0.90) == .excellent)
    }

    @Test("Hybrid score never exceeds 0.95 cap")
    func hybridScoreCap() {
        let score = service.calculateHybridScore(
            embeddingScore: 0.72,
            skillOverlap: 1.0,
            seniorityFit: 1.0,
            hasJobSkills: true
        )
        #expect(score == 0.95)
    }
}
