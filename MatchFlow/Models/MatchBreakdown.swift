//
//  MatchBreakdown.swift
//  MatchFlow
//

import Foundation

/// Per-job match components shown in Job Detail (0.0 ... 1.0).
struct MatchBreakdown: Equatable {
    let overallScore: Double
    let experienceScore: Double
    let skillsCoverage: Double
    let levelFit: Double
    let matchedSkillsCount: Int
    let totalJobSkillsCount: Int

    var experiencePercent: Int { Int(experienceScore * 100) }
    var skillsPercent: Int { Int(skillsCoverage * 100) }
    var levelPercent: Int { Int(levelFit * 100) }
    var overallPercent: Int { Int(overallScore * 100) }

    init(
        overallScore: Double,
        experienceScore: Double,
        skillsCoverage: Double,
        levelFit: Double,
        matchedSkillsCount: Int = 0,
        totalJobSkillsCount: Int = 0
    ) {
        self.overallScore = overallScore
        self.experienceScore = experienceScore
        self.skillsCoverage = skillsCoverage
        self.levelFit = levelFit
        self.matchedSkillsCount = matchedSkillsCount
        self.totalJobSkillsCount = totalJobSkillsCount
    }

    static func from(job: Job) -> MatchBreakdown? {
        guard let overall = job.matchScore else { return nil }
        return MatchBreakdown(
            overallScore: overall,
            experienceScore: job.experienceScore ?? 0,
            skillsCoverage: job.skillsCoverage ?? 0,
            levelFit: job.levelFit ?? 0,
            matchedSkillsCount: Int(((job.skillsCoverage ?? 0) * Double(job.skills.count)).rounded()),
            totalJobSkillsCount: job.skills.count
        )
    }
}
