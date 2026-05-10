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
        let job = try await supabase
            .from("jobs")
            .insert([
                "user_id": userId.uuidString,
                "url": url ?? "",
                "raw_text": rawText,
                "title": title ?? "",
                "company": company ?? "",
                "status": "applied"
            ])
            .select()
            .single()
            .execute()
            .value as Job
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
}
