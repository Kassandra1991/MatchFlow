//
//  ResumeService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Supabase

class ResumeService {
    static let shared = ResumeService()
    
    func saveResume(userId: UUID, rawText: String) async throws -> Resume {
        let resume: Resume = try await supabase
            .from("resumes")
            .insert([
                "user_id": userId.uuidString,
                "raw_text": rawText
            ])
            .select()
            .single()
            .execute()
            .value
        return resume
    }
    
    func fetchResume(userId: UUID) async throws -> Resume? {
        let resumes: [Resume] = try await supabase
            .from("resumes")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return resumes.first
    }
}
