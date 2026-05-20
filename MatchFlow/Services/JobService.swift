//
//  JobService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Supabase


protocol JobServiceProtocol {
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?) async throws -> Job
    func fetchJobs(userId: UUID) async throws -> [Job]
    func fetchJob(jobId: UUID) async throws -> Job
    func updateStatus(jobId: UUID, status: JobStatus) async throws
    func updateMatchScore(jobId: UUID, score: Double) async throws
    func checkPendingJob() -> (url: String?, text: String?)
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws
    func fetchJobText(from urlString: String) async throws -> String
    func saveAnalysis(jobId: UUID, analysis: JobAnalysis, rawText: String?) async throws
    func saveCoverLetter(jobId: UUID, coverLetter: String) async throws
    func deleteJob(jobId: UUID) async throws
}

struct JobService: JobServiceProtocol {
    
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?) async throws -> Job {
        let embedding = try await AIService().getEmbedding(for: rawText)
        let embeddingString = "[" + embedding.map { String($0) }.joined(separator: ",") + "]"
        
        let analysis = try await AIService().analyzeJob(description: rawText)
        
        let job: Job = try await supabase
            .from("jobs")
            .insert([
                "user_id": userId.uuidString,
                "url": url ?? "",
                "raw_text": rawText,
                "title": analysis.title ?? title ?? "",
                "company": analysis.company ?? company ?? "",
                "status": "exploring",
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
    
    func fetchJob(jobId: UUID) async throws -> Job {
        let job: Job = try await supabase
            .from("jobs")
            .select()
            .eq("id", value: jobId.uuidString)
            .single()
            .execute()
            .value
        return job
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
        let defaults = UserDefaults(suiteName: "group.com.asichka.jobmatch")
        let url = defaults?.string(forKey: "pendingJobURL")
        let text = defaults?.string(forKey: "pendingJobText")
        defaults?.removeObject(forKey: "pendingJobURL")
        defaults?.removeObject(forKey: "pendingJobText")
        defaults?.synchronize()
        return (url, text)
    }
    
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws {
        guard let resume = try await ResumeService().fetchDefaultResume(userId: userId) else { return }
        guard let resumeText = resume.rawText else { return }
        let resumeEmbedding = try await AIService().getEmbedding(for: resumeText)
        guard let jobText = job.rawText else { return }
        let jobEmbedding = try await AIService().getEmbedding(for: jobText)
        let score = AIService().calculateMatchScore(
            resumeEmbedding: resumeEmbedding,
            jobEmbedding: jobEmbedding
        )
        try await updateMatchScore(jobId: job.id, score: score)
    }
    
    func fetchJobText(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        let cleaned = html
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return String(cleaned.prefix(4000))
    }
    
    func saveAnalysis(jobId: UUID, analysis: JobAnalysis, rawText: String?) async throws {
        let skillsJSON = try? JSONEncoder().encode(analysis.skills)
        let skillsString = skillsJSON.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        try await supabase
            .from("jobs")
            .update([
                "summary": analysis.summary ?? "",
                "difficulty": analysis.difficulty ?? "",
                "title": analysis.title ?? "",
                "company": analysis.company ?? "",
                "skills": skillsString
            ])
            .eq("id", value: jobId.uuidString)
            .execute()
    }
    
    func saveCoverLetter(jobId: UUID, coverLetter: String) async throws {
        try await supabase
            .from("jobs")
            .update(["cover_letter": coverLetter])
            .eq("id", value: jobId.uuidString)
            .execute()
    }
    
    func deleteJob(jobId: UUID) async throws {
        try await supabase
            .from("jobs")
            .delete()
            .eq("id", value: jobId.uuidString)
            .execute()
    }
}
