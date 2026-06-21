//
//  CompanyLogoURL.swift
//  MatchFlow
//

import Foundation

enum CompanyLogoURL {
    static func normalizedDisplayURL(from raw: String?) -> URL? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
        guard !isLikelyJobSharePreview(url) else { return nil }
        return url
    }

    static func needsRefresh(raw: String?) -> Bool {
        guard let raw else { return true }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return true }
        if isLikelyJobSharePreview(url) { return true }
        return !url.absoluteString.lowercased().contains("company-logo")
    }

    static func isLikelyJobSharePreview(_ url: URL) -> Bool {
        let value = url.absoluteString.lowercased()
        if value.contains("company-logo") { return false }
        if value.contains("opengraph") { return true }
        if value.contains("jobs-share") { return true }
        if value.contains("feedshare") { return true }
        if value.contains("/jobs/") && !value.contains("company-logo") { return true }
        return false
    }
}
