//
//  InsightsAddJobCard.swift
//  MatchFlow
//

import SwiftUI

struct InsightsAddJobCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.s16) {
                ZStack {
                    RoundedRectangle(cornerRadius: DSRadius.rMax)
                        .fill(Color.backgroundAccent)
                        .frame(
                            width: InsightsHeroLayout.addJobPlusWidth,
                            height: InsightsHeroLayout.addJobPlusHeight
                        )
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.foregroundAccent)
                }

                VStack(alignment: .leading, spacing: DSSpacing.s4) {
                    Text("Add a job")
                        .textStyle(.body1Semibold)
                        .foregroundStyle(Color.foregroundPrimary)
                    Text("Paste a job link or description")
                        .textStyle(.captionRegular)
                        .foregroundStyle(Color.foregroundSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.foregroundSecondary)
            }
            .padding(DSSpacing.s16)
            .background(Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: DSRadius.rMax))
        }
        .buttonStyle(.plain)
    }
}
