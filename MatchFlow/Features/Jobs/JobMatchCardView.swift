//
//  JobMatchCardView.swift
//  MatchFlow
//

import SwiftUI

struct JobMatchCardView: View {
    let job: Job
    let breakdown: MatchBreakdown
    let improvementSuggestion: String?
    let isLoadingImprovement: Bool

    private var tier: MatchScoreTier { MatchScoreTier(score: breakdown.overallScore) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            subtitleRow
                .padding(.top, DSSpacing.s4)
            MatchBreakdownView(breakdown: breakdown)
                .padding(.top, DSSpacing.s24)

            if job.status == .exploring {
                exploringImprovementBanner
                    .padding(.top, DSSpacing.s24)
            }
        }
        .padding(.horizontal, DSSpacing.s16)
        .padding(.vertical, DSSpacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .jobDetailCard()
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: DSSpacing.s8) {
            Text(tier.detailTitle)
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
            MatchPercentCapsule(percent: breakdown.overallPercent, tier: tier)
            Spacer(minLength: 0)
        }
    }

    private var subtitleRow: some View {
        Text(matchSubtitle)
            .textStyle(.captionRegular)
            .foregroundStyle(Color.foregroundSecondary)
    }

    private var matchSubtitle: String {
        let date = (job.status == .exploring ? job.createdAt : job.appliedAt)
            .formatted(date: .abbreviated, time: .omitted)
        if job.status == .exploring {
            return "Match while exploring • \(date)"
        }
        return "Match at application • \(date)"
    }

    @ViewBuilder
    private var exploringImprovementBanner: some View {
        if isLoadingImprovement {
            improvementBanner {
                ProgressView()
                Text("Generating suggestions...")
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else if let improvementSuggestion, !improvementSuggestion.isEmpty {
            improvementBanner {
                Image(systemName: "sparkles")
                    .font(DSTextStyle.header1.font)
                    .foregroundStyle(Color.foregroundAccent)
                Text(improvementSuggestion)
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func improvementBanner<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .center, spacing: DSSpacing.s24) {
            content()
        }
        .padding(DSSpacing.s24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundAccent, in: RoundedRectangle(cornerRadius: DSRadius.r16))
    }
}
