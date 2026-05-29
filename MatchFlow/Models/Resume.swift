//
//  Resume.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation

struct Resume: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var title: String
    var rawText: String?
    var skillsRaw: String?
    var yearsExperience: Int?
    var seniority: String?
    var isDefault: Bool
    var createdAt: Date

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
        case title
        case rawText = "raw_text"
        case skillsRaw = "skills"
        case yearsExperience = "years_experience"
        case seniority
        case isDefault = "is_default"
        case createdAt = "created_at"
    }
}
