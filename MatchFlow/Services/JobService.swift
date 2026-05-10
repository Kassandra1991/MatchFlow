//
//  JobService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Supabase

class JobService {
    static let shared = JobService()
    
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?) async throws -> Job {
        // 1. Получаем embedding
        let embedding = try await AIService.shared.getEmbedding(for: rawText)
        let embeddingString = "[" + embedding.map { String($0) }.joined(separator: ",") + "]"
        
        // 2. Анализируем вакансию
        let analysis = try await AIService.shared.analyzeJob(description: rawText)
        
        // 3. Сохраняем в Supabase
        let job: Job = try await supabase
            .from("jobs")
            .insert([
                "user_id": userId.uuidString,
                "url": url ?? "",
                "raw_text": rawText,
                "title": analysis.title ?? title ?? "",
                "company": analysis.company ?? company ?? "",
                "status": "applied",
                "embedding": embeddingString
            ])
            .select()
            .single()
            .execute()
            .value
        return job
    }
    
    func fetchJobs(userId: UUID) async throws -> [Job] {
        let jobs: [Job] = try await supabase
            .from("jobs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return jobs
    }
    
    func updateStatus(jobId: UUID, status: JobStatus) async throws {
        try await supabase
            .from("jobs")
            .update(["status": status.rawValue])
            .eq("id", value: jobId.uuidString)
            .execute()
    }
    
    func updateMatchScore(jobId: UUID, score: Double) async throws {
        try await supabase
            .from("jobs")
            .update(["match_score": score])
            .eq("id", value: jobId.uuidString)
            .execute()
    }
    
    func checkPendingJob() -> (url: String?, text: String?) {
        let defaults = UserDefaults(suiteName: "group.com.asichka.matchflow")
        let url = defaults?.string(forKey: "pendingJobURL")
        let text = defaults?.string(forKey: "pendingJobText")
        
        // Очищаем после прочтения
        defaults?.removeObject(forKey: "pendingJobURL")
        defaults?.removeObject(forKey: "pendingJobText")
        defaults?.synchronize()
        
        return (url, text)
    }
    
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws {
        // 1. Берём дефолтное резюме
        guard let resume = try await ResumeService.shared.fetchDefaultResume(userId: userId) else { return }
        
        // 2. Получаем embedding резюме из Supabase
        guard let resumeText = resume.rawText else { return }
        let resumeEmbedding = try await AIService.shared.getEmbedding(for: resumeText)
        
        // 3. Получаем embedding вакансии
        guard let jobText = job.rawText else { return }
        let jobEmbedding = try await AIService.shared.getEmbedding(for: jobText)
        
        // 4. Считаем cosine similarity
        let score = AIService.shared.calculateMatchScore(
            resumeEmbedding: resumeEmbedding,
            jobEmbedding: jobEmbedding
        )
        
        // 5. Сохраняем
        try await updateMatchScore(jobId: job.id, score: score)
    }
    
    func fetchJobText(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        
        // Базовая очистка HTML тегов
        let cleaned = html
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return String(cleaned.prefix(4000)) // Лимит для OpenAI
    }
}
