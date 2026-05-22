//
//  AnalyticsService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 23/05/2026.
//

import Foundation
import FirebaseAnalytics

struct AnalyticsService {
    static func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}

enum AnalyticsEvent {
    // MARK: - Auth
    case signUp
    case signIn
    
    // MARK: - Jobs
    case jobAdded(source: String) // "manual", "share_extension"
    case jobDeleted
    case jobStatusChanged(from: String, to: String)
    case jobDetailOpened
    
    // MARK: - Features
    case aiAnalysisViewed
    case coverLetterOpened
    case coverLetterCopied
    case resumeUploaded
    case insightsViewed
    
    // MARK: - Navigation
    case tabOpened(name: String) // "insights", "jobs", "profile"
    
    var name: String {
        switch self {
        case .signUp: return "sign_up"
        case .signIn: return "sign_in"
        case .jobAdded: return "job_added"
        case .jobDeleted: return "job_deleted"
        case .jobStatusChanged: return "job_status_changed"
        case .jobDetailOpened: return "job_detail_opened"
        case .aiAnalysisViewed: return "ai_analysis_viewed"
        case .coverLetterOpened: return "cover_letter_opened"
        case .coverLetterCopied: return "cover_letter_copied"
        case .resumeUploaded: return "resume_uploaded"
        case .insightsViewed: return "insights_viewed"
        case .tabOpened: return "tab_opened"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .jobAdded(let source):
            return ["source": source]
        case .jobStatusChanged(let from, let to):
            return ["from": from, "to": to]
        case .tabOpened(let name):
            return ["tab_name": name]
        default:
            return nil
        }
    }
}
