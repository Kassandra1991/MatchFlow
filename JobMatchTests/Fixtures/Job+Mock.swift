//
//  Job+Mock.swift
//  JobMatchTests
//
//  Created by Aleksandra Asichka on 17/05/2026.
//

import Foundation
@testable import MatchFlow

extension Job {
    static func mock(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        title: String? = "iOS Developer",
        company: String? = "Apple",
        rawText: String? = "Job description",
        matchScore: Double? = 0.75,
        experienceScore: Double? = 0.65,
        skillsCoverage: Double? = 0.5,
        levelFit: Double? = 0.85,
        status: JobStatus = .applied,
        summary: String? = nil,
        skills: [String] = [],
        difficulty: String? = nil,
        coverLetter: String? = nil,
        notes: String? = nil,
        url: String? = nil,
        appliedAt: Date = Date(),
        createdAt: Date = Date()
    ) -> Job {
        Job(
            id: id,
            userId: userId,
            url: url,
            title: title,
            company: company,
            companyLogoUrl: nil,
            rawText: rawText,
            matchScore: matchScore,
            experienceScore: experienceScore,
            skillsCoverage: skillsCoverage,
            levelFit: levelFit,
            status: status,
            coverLetter: coverLetter,
            notes: notes,
            summary: summary,
            skillsRaw: skills.isEmpty ? nil : (try? String(data: JSONEncoder().encode(skills), encoding: .utf8) ?? nil),
            difficulty: difficulty,
            appliedAt: appliedAt,
            createdAt: createdAt
        )
    }
}
