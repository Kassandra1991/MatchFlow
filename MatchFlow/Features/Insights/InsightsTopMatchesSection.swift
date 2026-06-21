//
//  InsightsTopMatchesSection.swift
//  MatchFlow
//

import SwiftUI

struct InsightsTopMatchesSection: View {
    let isOnboarding: Bool
    let jobs: [Job]
    let topMatchesInsight: String?
    let isLoadingInsights: Bool
    let onJobTap: (UUID) -> Void

    private static let skeletonPercents = [87, 72, 68]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s16) {
            Text("Top job matches")
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .padding(.leading, DSSpacing.s16)

            VStack(spacing: 0) {
                if isOnboarding {
                    onboardingContent
                } else {
                    activeContent
                }
            }
            .jobDetailCard()
        }
    }

    private var onboardingContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s16) {
            VStack(spacing: 0) {
                ForEach(Array(Self.skeletonPercents.enumerated()), id: \.offset) { _, percent in
                    InsightsMatchSkeletonRow(percent: percent)
                }
            }
            .padding(.leading, DSSpacing.s24)
            .padding(.trailing, DSSpacing.s8)
            .padding(.top, DSSpacing.s16)

            VStack(alignment: .leading, spacing: DSSpacing.s8) {
                Text("Your top matching jobs will appear here")
                    .textStyle(.body1Semibold)
                    .foregroundStyle(Color.foregroundPrimary)

                Text("Add a few jobs to see how well they match your CV. Each job helps us refine your profile and improve the relevance of future recommendations.")
                    .textStyle(.captionRegular)
                    .foregroundStyle(Color.foregroundSecondary)
            }
            .padding(.horizontal, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s16)
        }
    }

    @ViewBuilder
    private var activeContent: some View {
        if shouldShowInsightBanner {
            InsightsTopMatchesInsightBanner(
                insight: topMatchesInsight,
                isLoading: isLoadingInsights
            )
        }

        if jobs.isEmpty && !isLoadingInsights {
            analyzingPlaceholder
        } else {
            VStack(spacing: DSSpacing.s32) {
                ForEach(jobs) { job in
                    Button {
                        onJobTap(job.id)
                    } label: {
                        JobRowView(job: job, style: .insightsCard)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, DSSpacing.s24)
            .padding(.trailing, DSSpacing.s8)
            .padding(.bottom, DSSpacing.s32)
        }
    }

    private var shouldShowInsightBanner: Bool {
        isLoadingInsights || (topMatchesInsight.map { !$0.isEmpty } ?? false)
    }

    private var analyzingPlaceholder: some View {
        HStack(spacing: DSSpacing.s8 + DSSpacing.s4) {
            ProgressView()
            Text("Analyzing your matches…")
                .textStyle(.body2Regular)
                .foregroundStyle(Color.foregroundSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.s24)
    }
}
