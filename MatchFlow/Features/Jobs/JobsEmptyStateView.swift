//
//  JobsEmptyStateView.swift
//  MatchFlow
//

import SwiftUI

struct JobsEmptyStateView: View {
    let filter: JobStatus?

    var body: some View {
        VStack(spacing: DSSpacing.s16) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.foregroundSecondary)
            Text(JobStatusStyle.emptyStateMessage(for: filter))
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    JobsEmptyStateView(filter: .applied)
}
