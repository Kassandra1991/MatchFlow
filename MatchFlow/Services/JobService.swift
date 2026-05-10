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
}
