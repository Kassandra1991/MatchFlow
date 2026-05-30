//
//  MatchBreakdownView.swift
//  MatchFlow
//

import SwiftUI

struct MatchBreakdownView: View {
    let breakdown: MatchBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MatchFactorRow(
                title: "Relevant Experience",
                subtitle: "Similarity between your CV and this job description",
                value: breakdown.experienceScore
            )
            MatchFactorRow(
                title: "Skills Coverage",
                subtitle: skillsSubtitle,
                value: breakdown.skillsCoverage
            )
            MatchFactorRow(
                title: "Career Level Fit",
                subtitle: "Alignment between your experience level and role expectations",
                value: breakdown.levelFit
            )
        }
        .padding(.vertical, 4)
    }

    private var skillsSubtitle: String {
        guard breakdown.totalJobSkillsCount > 0 else {
            return "No job skills extracted yet"
        }
        return "Matched \(breakdown.matchedSkillsCount) of \(breakdown.totalJobSkillsCount) job skills"
    }
}

private struct MatchFactorRow: View {
    let title: String
    let subtitle: String
    let value: Double

    private var tier: MatchScoreTier { MatchScoreTier(score: value) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.08))
                    Capsule()
                        .fill(tier.foregroundColor.opacity(0.85))
                        .frame(width: max(0, geo.size.width * CGFloat(min(1, max(0, value)))))
                }
            }
            .frame(height: 8)
        }
    }
}
