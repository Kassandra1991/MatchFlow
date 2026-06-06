//
//  ResumeService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Supabase
import PDFKit

protocol ResumeServiceProtocol {
    func saveResume(userId: UUID, title: String, rawText: String, isDefault: Bool) async throws -> Resume
    func fetchResumes(userId: UUID) async throws -> [Resume]
    func fetchDefaultResume(userId: UUID) async throws -> Resume?
    func setDefault(resumeId: UUID, userId: UUID) async throws
    func deleteResume(resumeId: UUID) async throws
    func extractTextFromPDF(url: URL) -> String
}

struct ResumeService: ResumeServiceProtocol {
    private let aiService: AIServiceProtocol

    init(aiService: AIServiceProtocol = AIService()) {
        self.aiService = aiService
    }

    func extractTextFromPDF(url: URL) -> String {
        guard url.startAccessingSecurityScopedResource() else { return "" }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let pdf = PDFDocument(url: url) else { return "" }

        var text = ""
        for index in 0..<pdf.pageCount {
            if let page = pdf.page(at: index) {
                text += (page.string ?? "") + "\n"
            }
        }
        return text
    }
    
    func saveResume(userId: UUID, title: String, rawText: String, isDefault: Bool = true) async throws -> Resume {
        try await supabase
            .from("resumes")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        let embedding = try await aiService.getEmbedding(for: rawText)
        let embeddingString = "[" + embedding.map { String($0) }.joined(separator: ",") + "]"

        let profile = try await aiService.extractResumeProfile(from: rawText)
        let skillsString = (try? JSONEncoder().encode(profile.skills))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let payload = ResumeInsertPayload(
            user_id: userId.uuidString,
            title: title,
            raw_text: rawText,
            skills: skillsString,
            embedding: embeddingString,
            is_default: isDefault,
            years_experience: profile.yearsExperience,
            seniority: profile.seniority
        )

        let resume: Resume = try await supabase
            .from("resumes")
            .insert(payload)
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
        
        if let resume = resumes.first {
            return resume
        }
        
        let allResumes: [Resume] = try await supabase
            .from("resumes")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value
        
        return allResumes.first
    }
    
    func setDefault(resumeId: UUID, userId: UUID) async throws {
        try await supabase
            .from("resumes")
            .update(["is_default": false])
            .eq("user_id", value: userId.uuidString)
            .execute()
        
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

private struct ResumeInsertPayload: Encodable {
    let user_id: String
    let title: String
    let raw_text: String
    let skills: String
    let embedding: String
    let is_default: Bool
    let years_experience: Int?
    let seniority: String?
}
