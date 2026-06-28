//
//  JobService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Supabase


protocol JobServiceProtocol {
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?, companyLogoUrl: String?) async throws -> Job
    func addJobFromShare(userId: UUID) async throws -> Job?
    func addJobFromURL(userId: UUID, url: String) async throws -> Job
    func fetchJobs(userId: UUID) async throws -> [Job]
    func fetchJob(jobId: UUID) async throws -> Job
    func updateStatus(jobId: UUID, status: JobStatus) async throws
    func updateMatchScore(jobId: UUID, score: Double) async throws
    func updateMatchResults(jobId: UUID, breakdown: MatchBreakdown) async throws
    func checkPendingJob() -> (url: String?, text: String?)
    func calculateAndSaveMatchScore(job: Job, userId: UUID) async throws
    func fetchJobText(from urlString: String) async throws -> String
    func saveAnalysis(jobId: UUID, analysis: JobAnalysis, rawText: String?) async throws
    func saveCoverLetter(jobId: UUID, coverLetter: String) async throws
    func saveNotes(jobId: UUID, notes: String) async throws
    func saveImprovementSuggestion(jobId: UUID, suggestion: String) async throws
    func updateCompanyLogoUrl(jobId: UUID, logoUrl: String) async throws
    func clearImprovementSuggestions(userId: UUID) async throws
    func deleteJob(jobId: UUID) async throws
}

struct JobService: JobServiceProtocol {
    private let aiService: AIServiceProtocol
    private let resumeService: ResumeServiceProtocol

    init(
        aiService: AIServiceProtocol = AIService(),
        resumeService: ResumeServiceProtocol = ResumeService()
    ) {
        self.aiService = aiService
        self.resumeService = resumeService
    }

    func addJobFromShare(userId: UUID) async throws -> Job? {
        let pending = checkPendingJob()
        guard let url = pending.url ?? pending.text else { return nil }
        return try await addJobFromURL(userId: userId, url: url)
    }

    func addJobFromURL(userId: UUID, url: String) async throws -> Job {
        guard let trimmed = AddJobImportLayout.normalizedJobURL(url) else {
            throw URLError(.badURL)
        }

        var rawText = trimmed
        var title: String?
        var company: String?
        var companyLogoUrl: String?

        if trimmed.contains("linkedin.com/jobs/view") {
            let jobData = try await aiService.fetchJobFromURL(trimmed)
            rawText = jobData.description ?? trimmed
            title = jobData.title
            company = jobData.company
            companyLogoUrl = jobData.companyLogo
        } else {
            rawText = (try? await fetchJobText(from: trimmed)) ?? trimmed
        }

        let job = try await addJob(
            userId: userId,
            url: trimmed,
            rawText: rawText,
            title: title,
            company: company,
            companyLogoUrl: companyLogoUrl
        )
        try await calculateAndSaveMatchScore(job: job, userId: userId)
        return job
    }
    
    func addJob(userId: UUID, url: String?, rawText: String, title: String?, company: String?, companyLogoUrl: String? = nil) async throws -> Job {
        let englishText = try await aiService.ensureEnglishJobText(rawText)

        let embedding = try await aiService.getEmbedding(for: englishText)
        let embeddingString = "[" + embedding.map { String($0) }.joined(separator: ",") + "]"
        
        let analysis = try await aiService.analyzeJob(description: englishText)

        let skillsJSON = (try? JSONEncoder().encode(analysis.skills))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let trimmedCompany = company?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedCompany = trimmedCompany.isEmpty
            ? (analysis.company ?? "")
            : trimmedCompany

        let job: Job = try await supabase
            .from("jobs")
            .insert([
                "user_id": userId.uuidString,
                "url": url ?? "",
                "raw_text": englishText,
                "title": analysis.title ?? title ?? "",
                "company": resolvedCompany,
                "company_logo_url": companyLogoUrl ?? "",
                "summary": analysis.summary ?? "",
                "difficulty": analysis.difficulty ?? "",
                "skills": skillsJSON,
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
        try await updateMatchResults(
            jobId: jobId,
            breakdown: MatchBreakdown(
                overallScore: score,
                experienceScore: 0,
                skillsCoverage: 0,
                levelFit: 0
            )
        )
    }

    func updateMatchResults(jobId: UUID, breakdown: MatchBreakdown) async throws {
        try await supabase
            .from("jobs")
            .update([
                "match_score": breakdown.overallScore,
                "experience_score": breakdown.experienceScore,
                "skills_coverage": breakdown.skillsCoverage,
                "level_fit": breakdown.levelFit
            ])
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
        guard let resume = try await resumeService.fetchDefaultResume(userId: userId) else { return }
        guard let resumeText = resume.rawText else { return }
        guard let jobText = job.rawText else { return }

        let resumeEmbedding = try await aiService.getEmbedding(for: resumeText)
        let jobTextEnglish = try await aiService.ensureEnglishJobText(jobText)
        let jobEmbedding = try await aiService.getEmbedding(for: jobTextEnglish)
        let embeddingScore = aiService.calculateMatchScore(
            resumeEmbedding: resumeEmbedding,
            jobEmbedding: jobEmbedding
        )

        let seniorityFit = aiService.calculateSeniorityFit(
            resumeSeniority: resume.seniority,
            resumeYears: resume.yearsExperience,
            jobDifficulty: job.difficulty
        )

        let hasJobSkills = !job.skills.isEmpty
        let matched = hasJobSkills && !resume.skills.isEmpty
            ? aiService.matchedJobSkills(resumeSkills: resume.skills, jobSkills: job.skills)
            : []
        let skillOverlap: Double = hasJobSkills && !resume.skills.isEmpty
            ? Double(matched.count) / Double(job.skills.count)
            : 0

        let breakdown = aiService.buildMatchBreakdown(
            embeddingScore: embeddingScore,
            skillOverlap: skillOverlap,
            seniorityFit: seniorityFit,
            hasJobSkills: hasJobSkills,
            matchedSkillsCount: matched.count,
            totalJobSkillsCount: job.skills.count
        )

        try await updateMatchResults(jobId: job.id, breakdown: breakdown)
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

    func saveNotes(jobId: UUID, notes: String) async throws {
        try await supabase
            .from("jobs")
            .update(["notes": notes])
            .eq("id", value: jobId.uuidString)
            .execute()
    }

    func saveImprovementSuggestion(jobId: UUID, suggestion: String) async throws {
        try await supabase
            .from("jobs")
            .update(["improvement_suggestion": suggestion])
            .eq("id", value: jobId.uuidString)
            .execute()
    }

    func updateCompanyLogoUrl(jobId: UUID, logoUrl: String) async throws {
        try await supabase
            .from("jobs")
            .update(["company_logo_url": logoUrl])
            .eq("id", value: jobId.uuidString)
            .execute()
    }

    func clearImprovementSuggestions(userId: UUID) async throws {
        struct ImprovementClear: Encodable {
            let improvement_suggestion: String?
        }
        try await supabase
            .from("jobs")
            .update(ImprovementClear(improvement_suggestion: nil))
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: JobStatus.exploring.rawValue)
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
