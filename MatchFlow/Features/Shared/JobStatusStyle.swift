//
//  JobStatusStyle.swift
//  MatchFlow
//

import SwiftUI

enum JobStatusStyle {
    static func color(for status: JobStatus) -> Color {
        switch status {
        case .exploring: return .gray
        case .applied: return .blue
        case .interview: return .orange
        case .rejected: return .red
        case .offer: return .green
        }
    }

    static func label(for status: JobStatus) -> String {
        status.rawValue.capitalized
    }
}
