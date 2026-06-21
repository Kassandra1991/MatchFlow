//
//  InsightsMatchSkeletonRow.swift
//  MatchFlow
//

import SwiftUI

struct InsightsMatchSkeletonRow: View {
    let percent: Int

    private var tier: MatchScoreTier {
        MatchScoreTier(score: Double(percent) / 100)
    }

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.s16) {
            Circle()
                .fill(Color.placeholderDefault)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: DSSpacing.s4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.placeholderDefault)
                    .frame(height: 14)
                    .frame(maxWidth: 160)

                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: DSSpacing.s4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.placeholderDefault)
                            .frame(height: 12)
                            .frame(maxWidth: 120)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.placeholderDefault)
                            .frame(height: 12)
                            .frame(maxWidth: 80)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: DSSpacing.s16)

                    HStack(spacing: DSSpacing.s8) {
                        MatchPercentCapsule(percent: percent, tier: tier)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.foregroundMinor)
                            .frame(width: 14, height: 20, alignment: .center)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DSSpacing.s8)
    }
}
