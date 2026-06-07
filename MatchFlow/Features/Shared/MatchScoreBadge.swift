//
//  MatchScoreBadge.swift
//  MatchFlow
//

import SwiftUI

struct MatchScoreBadge: View {
    let score: Double

    private var tier: MatchScoreTier { MatchScoreTier(score: score) }
    private var percent: Int { Int(score * 100) }

    var body: some View {
        VStack(spacing: DSSpacing.s2) {
            Text(tier.primaryLabel(percent: percent))
                .textStyle(.body2Semibold)
            if let secondary = tier.secondaryLabel(percent: percent) {
                Text(secondary)
                    .textStyle(.captionSemibold)
            }
        }
        .padding(.horizontal, DSSpacing.s8 + DSSpacing.s4)
        .padding(.vertical, DSSpacing.s4 + DSSpacing.s2)
        .background(tier.backgroundColor)
        .foregroundStyle(tier.foregroundColor)
        .clipShape(Capsule())
    }
}
