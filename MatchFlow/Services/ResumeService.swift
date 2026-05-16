//
//  ResumeService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Supabase

protocol ResumeServiceProtocol {
    func saveResume(userId: UUID, title: String, rawText: String, isDefault: Bool) async throws -> Resume
    func fetchResumes(userId: UUID) async throws -> [Resume]
    func fetchDefaultResume(userId: UUID) async throws -> Resume?
    func setDefault(resumeId: UUID, userId: UUID) async throws
    func deleteResume(resumeId: UUID) async throws
}

class ResumeService: ResumeServiceProtocol {
    static let shared = ResumeService()
    
    func saveResume(userId: UUID, title: String, rawText: String, isDefault: Bool = true) async throws -> Resume {
        // 1. Если isDefault — сбрасываем предыдущий дефолт
        if isDefault {
            try await supabase
                .from("resumes")
                .update(["is_default": false])
                .eq("user_id", value: userId.uuidString)
                .execute()
        }
        
        // 2. Получаем embedding
        let embedding = try await AIService.shared.getEmbedding(for: rawText)
        let embeddingString = "[" + embedding.map { String($0) }.joined(separator: ",") + "]"
        
        // 3. Сохраняем в Supabase
        let resume: Resume = try await supabase
            .from("resumes")
            .insert([
                "user_id": userId.uuidString,
                "title": title,
                "raw_text": rawText,
                "embedding": embeddingString,
                "is_default": isDefault ? "true" : "false"
            ])
            .select()
            .single()
            .execute()
            .value
        return resume
    }
    
    func fetchResumes(userId: UUID) async throws -> [Resume] {
        let resumes: [Resume] = try await supabase
            .from("resumes")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return resumes
    }
    
    func fetchDefaultResume(userId: UUID) async throws -> Resume? {
        let resumes: [Resume] = try await supabase
            .from("resumes")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_default", value: true)
            .limit(1)
            .execute()
            .value
        return resumes.first
    }
    
    func setDefault(resumeId: UUID, userId: UUID) async throws {
        // Сбрасываем все
        try await supabase
            .from("resumes")
            .update(["is_default": false])
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        // Устанавливаем новый дефолт
        try await supabase
            .from("resumes")
            .update(["is_default": true])
            .eq("id", value: resumeId.uuidString)
            .execute()
    }
    
    func deleteResume(resumeId: UUID) async throws {
        try await supabase
            .from("resumes")
            .delete()
            .eq("id", value: resumeId.uuidString)
            .execute()
    }
}
