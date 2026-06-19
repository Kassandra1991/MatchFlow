//
//  JobStatusStyle.swift
//  MatchFlow
//

import Foundation

enum JobStatusStyle {
    static func label(for status: JobStatus) -> String {
        status.rawValue.capitalized
    }

    static func listLabel(for status: JobStatus) -> String {
        switch status {
        case .exploring:
            return "Explored"
        default:
            return label(for: status)
        }
    }

    static func titleParts(for title: String?) -> (primary: String, secondary: String?) {
        guard let raw = title?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return ("Unknown Role", nil)
        }
        if raw.contains(" / ") {
            let parts = raw.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespaces) }
            return (parts[0], parts.count > 1 ? parts[1] : nil)
        }
        let words = raw.split(separator: " ")
        guard words.count > 1 else { return (raw, nil) }
        return (words.dropLast().joined(separator: " "), String(words.last!))
    }

    static func listSubtitle(secondaryTitle: String?, status: JobStatus) -> String {
        let statusLabel = listLabel(for: status)
        guard let secondaryTitle, !secondaryTitle.isEmpty else { return statusLabel }
        return "\(secondaryTitle) • \(statusLabel)"
    }

    static func emptyStateMessage(for filter: JobStatus?) -> String {
        guard let filter else { return "No jobs yet" }
        return "No \(filter.rawValue) jobs"
    }
}
