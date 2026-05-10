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
    var isDefault: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case rawText = "raw_text"
        case isDefault = "is_default"
        case createdAt = "created_at"
    }
}
