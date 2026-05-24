//
//  Job.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation

struct Job: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: UUID
    var url: String?
    var title: String?
    var company: String?
    var companyLogoUrl: String?
    var rawText: String?
    var matchScore: Double?
    var status: JobStatus
    var coverLetter: String?
    var notes: String?
    var summary: String?
    var skillsRaw: String?
    var difficulty: String?
    var appliedAt: Date
    var createdAt: Date
    
    // Computed property для удобства
    var skills: [String] {
        guard let raw = skillsRaw,
              let data = raw.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return array
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case url
        case title
        case company
        case companyLogoUrl = "company_logo_url"
        case rawText = "raw_text"
        case matchScore = "match_score"
        case status
        case coverLetter = "cover_letter"
        case notes
        case summary
        case skillsRaw = "skills"
        case difficulty
        case appliedAt = "applied_at"
        case createdAt = "created_at"
    }
}

enum JobStatus: String, Codable, CaseIterable {
    case exploring = "exploring"
    case applied = "applied"
    case interview = "interview"
    case rejected = "rejected"
    case offer = "offer"
}
