//
//  MatchBreakdownView.swift
//  MatchFlow
//

import SwiftUI

struct MatchBreakdownView: View {
    let breakdown: MatchBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s24) {
            MatchFactorRow(
                title: "Relevant experience",
                infoText: "Similarity between your CV and this job description",
                value: breakdown.experienceScore
            )
            MatchFactorRow(
                title: "Skills coverage",
                infoText: skillsInfoText,
                value: breakdown.skillsCoverage
            )
            MatchFactorRow(
                title: "Career level fit",
                infoText: "Alignment between your experience level and role expectations",
                value: breakdown.levelFit
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var skillsInfoText: String {
        guard breakdown.totalJobSkillsCount > 0 else {
            return "No job skills extracted yet"
        }
        return "Matched \(breakdown.matchedSkillsCount) of \(breakdown.totalJobSkillsCount) job skills"
    }
}

private struct MatchFactorRow: View {
    let title: String
    let infoText: String
    let value: Double

    @State private var showsInfo = false

    private var tier: MatchScoreTier { MatchScoreTier(score: value) }

    private var clampedValue: CGFloat {
        CGFloat(min(1, max(0, value)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s8) {
            HStack(spacing: DSSpacing.s8) {
                Text(title)
                    .textStyle(.body1Regular)
                    .foregroundStyle(Color.foregroundPrimary)
                Spacer()
                Button {
                    showsInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(DSTextStyle.body2Regular.font)
                        .foregroundStyle(Color.foregroundMinor)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showsInfo) {
                    Text(infoText)
                        .textStyle(.captionRegular)
                        .foregroundStyle(Color.foregroundSecondary)
                        .padding(DSSpacing.s16)
                        .presentationCompactAdaptation(.popover)
                }
            }

            Capsule()
                .fill(Color.backgroundMinor)
                .frame(maxWidth: .infinity)
                .frame(height: DSSpacing.s4)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(tier.foregroundColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.s4)
                        .scaleEffect(x: clampedValue, y: 1, anchor: .leading)
                }
        }
    }
}
