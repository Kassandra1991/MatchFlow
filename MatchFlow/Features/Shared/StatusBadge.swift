//
//  StatusBadge.swift
//  MatchFlow
//

import SwiftUI

struct StatusBadge: View {
    let status: JobStatus

    var body: some View {
        Text(JobStatusStyle.label(for: status))
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(JobStatusStyle.color(for: status).opacity(0.15))
            .foregroundColor(JobStatusStyle.color(for: status))
            .clipShape(Capsule())
    }
}
