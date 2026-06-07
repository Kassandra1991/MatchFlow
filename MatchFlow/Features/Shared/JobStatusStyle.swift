//
//  JobStatusStyle.swift
//  MatchFlow
//

import Foundation

enum JobStatusStyle {
    static func label(for status: JobStatus) -> String {
        status.rawValue.capitalized
    }
}
