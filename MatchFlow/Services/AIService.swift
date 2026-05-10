//
//  AIService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation

class AIService {
    static let shared = AIService()
    
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
