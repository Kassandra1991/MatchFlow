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
    var rawText: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case rawText = "raw_text"
        case createdAt = "created_at"
    }
}
