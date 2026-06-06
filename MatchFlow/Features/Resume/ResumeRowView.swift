//
//  ResumeRowView.swift
//  MatchFlow
//

import SwiftUI

struct ResumeRowView: View {
    let resume: Resume
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(resume.title)
                .font(.headline)
            Text("Uploaded \(resume.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
