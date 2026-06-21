//
//  JobDetailHeaderView.swift
//  MatchFlow
//

import SwiftUI

struct JobDetailHeaderView: View {
    let job: Job
    @Binding var selectedStatus: JobStatus

    var body: some View {
        VStack(spacing: 0) {
            CompanyLogoView(logoUrl: job.companyLogoUrl, style: .detail)

            Text(job.company ?? "Unknown Company")
                .textStyle(.header1)
                .foregroundStyle(Color.foregroundPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, DSSpacing.s24)

            Text(job.title ?? "Unknown Role")
                .textStyle(.body1Regular)
                .foregroundStyle(Color.foregroundSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, DSSpacing.s8)

            statusPicker
                .padding(.top, DSSpacing.s24)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ProfileLayout.headerTop)
    }

    private var statusPicker: some View {
        Menu {
            ForEach(JobStatus.allCases, id: \.self) { status in
                Button {
                    selectedStatus = status
                } label: {
                    if selectedStatus == status {
                        Label(JobStatusStyle.label(for: status), systemImage: "checkmark")
                    } else {
                        Text(JobStatusStyle.label(for: status))
                    }
                }
            }
        } label: {
            HStack(spacing: DSSpacing.s4) {
                Text(JobStatusStyle.label(for: selectedStatus))
                    .textStyle(.captionSemibold)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .padding(.horizontal, DSSpacing.s16)
            .padding(.vertical, DSSpacing.s8)
            .foregroundStyle(Color.foregroundPrimary)
            .background(Color.buttonSecondary, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
