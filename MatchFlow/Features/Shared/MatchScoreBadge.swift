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
        VStack(spacing: 2) {
            Text(tier.primaryLabel(percent: percent))
                .font(.subheadline)
                .fontWeight(.bold)
            if let secondary = tier.secondaryLabel(percent: percent) {
                Text(secondary)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(tier.backgroundColor)
        .foregroundColor(tier.foregroundColor)
        .clipShape(Capsule())
    }
}
