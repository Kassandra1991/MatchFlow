//
//  JobRowView.swift
//  MatchFlow
//

import SwiftUI

struct JobRowView: View {
    let job: Job
    
    var body: some View {
        HStack(spacing: 12) {
            if let logoUrl = job.companyLogoUrl, let url = URL(string: logoUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                }
                .frame(width: 44, height: 44)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "briefcase")
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(job.title ?? "Unknown Role")
                        .font(.headline)
                    Spacer()
                    StatusBadge(status: job.status)
                }
                Text(job.company ?? "Unknown Company")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let score = job.matchScore {
                    let tier = MatchScoreTier(score: score)
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(tier.foregroundColor)
                        Text(tier.rowLabel(percent: Int(score * 100)))
                            .font(.caption)
                            .foregroundColor(tier.foregroundColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(tier.backgroundColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
