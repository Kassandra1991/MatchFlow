//
//  StatusBadge.swift
//  MatchFlow
//

import SwiftUI

struct StatusBadge: View {
    let status: JobStatus

    var body: some View {
        Text(JobStatusStyle.label(for: status))
            .textStyle(.captionSemibold)
            .padding(.horizontal, DSSpacing.s8)
            .padding(.vertical, DSSpacing.s4)
            .background(Color.backgroundMinor)
            .foregroundStyle(Color.foregroundSecondary)
            .clipShape(Capsule())
    }
}
