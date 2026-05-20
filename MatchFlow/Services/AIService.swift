//
//  AIService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation

protocol AIServiceProtocol {
    func getEmbedding(for text: String) async throws -> [Float]
    func analyzeJob(description: String) async throws -> JobAnalysis
    func calculateMatchScore(resumeEmbedding: [Float], jobEmbedding: [Float]) -> Double
    func generateInsights(jobs: [Job]) async throws -> String
    func generateCoverLetter(resume: String, jobDescription: String, profile: UserProfile) async throws -> String
}

struct AIService: AIServiceProtocol {
    
    private let apiKey = Secrets.openAIKey
    private let embeddingURL = "https://api.openai.com/v1/embeddings"
    private let completionURL = "https://api.openai.com/v1/chat/completions"
    private let embeddingModel = "text-embedding-3-small"
    private let completionModel = "gpt-4o-mini"
    
    // MARK: - Embeddings
    func getEmbedding(for text: String) async throws -> [Float] {
        var request = URLRequest(url: URL(string: embeddingURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": embeddingModel,
            "input": text
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(EmbeddingResponse.self, from: data)
        return response.data.first?.embedding ?? []
    }
    
    // MARK: - Job Analysis
    func analyzeJob(description: String) async throws -> JobAnalysis {
        var request = URLRequest(url: URL(string: completionURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Analyze this job description and return JSON only:
        {
          "title": "job title",
          "company": "company name",
          "summary": "2-3 sentence summary",
          "skills": ["skill1", "skill2"],
          "difficulty": "junior/mid/senior"
        }

        Rules for skills:
        - Maximum 10 skills
        - Each skill max 3 words, prefer 1-2 words
        - Use short forms: "iOS" not "iOS Development", "SwiftUI" not "SwiftUI Framework"
        - Technical skills only, no soft skills

        Job description:
        \(description)
        """
        
        let body: [String: Any] = [
            "model": completionModel,
            "messages": [["role": "user", "content": prompt]],
            "response_format": ["type": "json_object"]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
        let content = response.choices.first?.message.content ?? "{}"
        return try JSONDecoder().decode(JobAnalysis.self, from: Data(content.utf8))
    }
    
    // MARK: - Match Score
    func calculateMatchScore(resumeEmbedding: [Float], jobEmbedding: [Float]) -> Double {
        guard resumeEmbedding.count == jobEmbedding.count else { return 0 }
        let dot = zip(resumeEmbedding, jobEmbedding).map(*).reduce(0, +)
        let normA = sqrt(resumeEmbedding.map { $0 * $0 }.reduce(0, +))
        let normB = sqrt(jobEmbedding.map { $0 * $0 }.reduce(0, +))
        guard normA > 0, normB > 0 else { return 0 }
        return Double(dot / (normA * normB))
    }
    
    func generateInsights(jobs: [Job]) async throws -> String {
        guard !jobs.isEmpty else { return "Add more jobs to get insights." }
        
        // Готовим данные для анализа
        let totalJobs = jobs.count
        let avgScore = jobs.compactMap { $0.matchScore }.reduce(0, +) / Double(max(jobs.compactMap { $0.matchScore }.count, 1))
        
        let statusCounts = Dictionary(grouping: jobs, by: { $0.status })
            .mapValues { $0.count }
        
        let allSkills = jobs.flatMap { $0.skills }
        let skillFrequency = Dictionary(grouping: allSkills, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(15)
            .map { "\($0.key) (\($0.value))" }
            .joined(separator: ", ")
        
        let topMatches = jobs
            .filter { $0.matchScore != nil }
            .sorted { ($0.matchScore ?? 0) > ($1.matchScore ?? 0) }
            .prefix(3)
            .map { "\($0.title ?? "Unknown") at \($0.company ?? "Unknown") — \(Int(($0.matchScore ?? 0) * 100))%" }
            .joined(separator: "; ")
        
        let interviewJobs = jobs.filter { $0.status == .interview }
            .map { "\($0.title ?? "Unknown") at \($0.company ?? "Unknown") — \(Int(($0.matchScore ?? 0) * 100))% match" }
            .joined(separator: "; ")
        
        let rejectedJobs = jobs.filter { $0.status == .rejected }
            .map { "\($0.title ?? "Unknown") — \(Int(($0.matchScore ?? 0) * 100))% match" }
            .joined(separator: "; ")
        
        let prompt = """
        You are a career coach analyzing job search data. Be concise and actionable.

        Data:
        - Total applications: \(totalJobs)
        - Average match score: \(Int(avgScore * 100))%
        - Applied: \(statusCounts[.applied] ?? 0), Interviews: \(statusCounts[.interview] ?? 0), Rejected: \(statusCounts[.rejected] ?? 0), Offers: \(statusCounts[.offer] ?? 0)
        - Top matching roles: \(topMatches.isEmpty ? "none yet" : topMatches)
        - Interviews received: \(interviewJobs.isEmpty ? "none yet" : interviewJobs)
        - Rejections: \(rejectedJobs.isEmpty ? "none yet" : rejectedJobs)
        - Most required skills across all jobs: \(skillFrequency.isEmpty ? "none yet" : skillFrequency)

        Return JSON only:
        {
          "summary": "3-4 sentence analysis: what's working, patterns in matches and rejections, what to improve"
        }
        """
        
        var request = URLRequest(url: URL(string: completionURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": completionModel,
            "messages": [["role": "user", "content": prompt]],
            "response_format": ["type": "json_object"]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
        return response.choices.first?.message.content ?? "{}"
    }
    
    func generateCoverLetter(resume: String, jobDescription: String, profile: UserProfile) async throws -> String {
        let tone = profile.coverLetterTone ?? "friendly"
        let important = profile.importantInCompany ?? ""
        let workStyle = profile.workStyle ?? ""
        let goals = profile.careerGoals ?? ""
        let name = profile.fullName ?? ""
        let headline = profile.headline ?? ""
        
        let prompt = """
        Write a cover letter for this job application.
        
        Candidate:
        - Name: \(name)
        - Role: \(headline)
        - What's important in a company: \(important)
        - Work style: \(workStyle)
        - Career goals: \(goals)
        
        Tone: \(tone)
        
        Resume summary:
        \(String(resume.prefix(2000)))
        
        Job description:
        \(String(jobDescription.prefix(2000)))
        
        Instructions:
        - Maximum 750 characters total
        - 1-2 short paragraphs
        - Match candidate values with company culture from job description
        - Be specific about why this role fits their goals
        - Tone must be \(tone)
        - No generic phrases like "I am writing to apply"
        - End with a clear call to action
        - Return plain text only, no markdown
        """
        
        var request = URLRequest(url: URL(string: completionURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": completionModel,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CompletionResponse.self, from: data)
        return response.choices.first?.message.content ?? ""
    }
}

// MARK: - Response Models
struct EmbeddingResponse: Codable {
    let data: [EmbeddingData]
}

struct EmbeddingData: Codable {
    let embedding: [Float]
}

struct CompletionResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

struct JobAnalysis: Codable {
    let title: String?
    let company: String?
    let summary: String?
    let skills: [String]?
    let difficulty: String?
}

struct JobInsights: Codable {
    let summary: String?
}
