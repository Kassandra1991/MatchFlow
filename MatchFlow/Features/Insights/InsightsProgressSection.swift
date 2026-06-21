//
//  InsightsProgressSection.swift
//  MatchFlow
//

import SwiftUI

struct InsightsProgressSection: View {
    let exploredCount: Int
    let appliedCount: Int
    let interviewCount: Int
    let rejectedCount: Int
    let offerCount: Int
    let onExploredTap: () -> Void
    let onAppliedTap: () -> Void
    let onInterviewTap: () -> Void
    let onRejectedTap: () -> Void
    let onOfferTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s16) {
            Text("Your progress")
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .padding(.leading, DSSpacing.s16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s8) {
                    InsightsProgressBadge(
                        count: exploredCount,
                        label: "Explored",
                        style: .explored,
                        action: onExploredTap
                    )
                    InsightsProgressBadge(
                        count: appliedCount,
                        label: "Applied",
                        style: .applied,
                        action: onAppliedTap
                    )
                    InsightsProgressBadge(
                        count: interviewCount,
                        label: "Interviews",
                        style: .interviews,
                        action: onInterviewTap
                    )
                    InsightsProgressBadge(
                        count: offerCount,
                        label: "Offer",
                        style: .offer,
                        action: onOfferTap
                    )
                    InsightsProgressBadge(
                        count: rejectedCount,
                        label: "Rejected",
                        style: .rejected,
                        action: onRejectedTap
                    )
                }
                .padding(.horizontal, DSSpacing.s2)
            }
            .scrollClipDisabled()
        }
    }
}
