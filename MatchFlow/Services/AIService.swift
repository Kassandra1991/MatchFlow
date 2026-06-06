//
//  AIService.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation

protocol AIServiceProtocol {
    func isPrimarilyEnglish(_ text: String) -> Bool
    func ensureEnglishJobText(_ text: String) async throws -> String
    func getEmbedding(for text: String) async throws -> [Float]
    func analyzeJob(description: String) async throws -> JobAnalysis
    func extractResumeProfile(from text: String) async throws -> ResumeProfile
    func calculateMatchScore(resumeEmbedding: [Float], jobEmbedding: [Float]) -> Double
    func calculateSkillOverlap(resumeSkills: [String], jobSkills: [String]) -> Double
    func matchedJobSkills(resumeSkills: [String], jobSkills: [String]) -> [String]
    func calculateSeniorityFit(resumeSeniority: String?, resumeYears: Int?, jobDifficulty: String?) -> Double
    func calculateHybridScore(embeddingScore: Double, skillOverlap: Double, seniorityFit: Double, hasJobSkills: Bool) -> Double
    func buildMatchBreakdown(
        embeddingScore: Double,
        skillOverlap: Double,
        seniorityFit: Double,
        hasJobSkills: Bool,
        matchedSkillsCount: Int,
        totalJobSkillsCount: Int
    ) -> MatchBreakdown
    func generateInsights(jobs: [Job]) async throws -> JobInsights
    func generateCoverLetter(resume: String, jobDescription: String, profile: UserProfile) async throws -> String
    func fetchJobFromURL(_ url: String) async throws -> (title: String?, company: String?, location: String?, description: String?, companyLogo: String?)
}

struct AIService: AIServiceProtocol {
    
    private let apiKey = Secrets.openAIKey
    private let embeddingURL = "https://api.openai.com/v1/embeddings"
    private let completionURL = "https://api.openai.com/v1/chat/completions"
    private let embeddingModel = "text-embedding-3-large"
    private let completionModel = "gpt-4o-mini"

    // MARK: - Job Text Language
    func isPrimarilyEnglish(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return true }

        var letterCount = 0
        var cyrillicCount = 0
        for scalar in text.unicodeScalars {
            guard CharacterSet.letters.contains(scalar) else { continue }
            letterCount += 1
            if (0x0400...0x04FF).contains(scalar.value) {
                cyrillicCount += 1
            }
        }
        guard letterCount > 0 else { return true }
        return Double(cyrillicCount) / Double(letterCount) <= 0.15
    }

    func ensureEnglishJobText(_ text: String) async throws -> String {
        guard !isPrimarilyEnglish(text) else { return text }

        var request = URLRequest(url: URL(string: completionURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Translate this job description to English.
        Preserve technical terms (Swift, iOS, SwiftUI, PostgreSQL, etc.) in standard English form.
        Return JSON only: {"text": "translated job description"}

        Job description:
        \(String(text.prefix(12000)))
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

        struct TranslationResponse: Codable { let text: String? }
        let parsed = try JSONDecoder().decode(TranslationResponse.self, from: Data(content.utf8))
        return parsed.text ?? text
    }
    
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
        - Maximum 15 skills
        - Include ALL technical skills explicitly mentioned in the job description
        - Do not drop niche tools or domain-specific requirements
        - Each skill max 3 words, prefer 1-2 words
        - Use short forms: "iOS" not "iOS Development", "SwiftUI" not "SwiftUI Framework"
        - Technical skills only, no soft skills
        
        Rules for difficulty:
        - Infer from job title AND requirements (years of experience, scope, leadership)
        - If title says "Senior" but only 2-3 years required, use "mid"
        - Return exactly one of: "junior", "mid", "senior"
        
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
    
    // MARK: - Resume Profile Extraction
    func extractResumeProfile(from text: String) async throws -> ResumeProfile {
        var request = URLRequest(url: URL(string: completionURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Extract profile data from this resume. Return JSON only:
        {
          "skills": ["skill1", "skill2"],
          "yearsOfExperience": 3,
          "seniority": "mid"
        }

        Rules for skills:
        - Maximum 30 skills
        - Include ALL technical skills explicitly mentioned in the resume
        - Do not drop niche tools, frameworks, or domain-specific technologies
        - Short forms: "SwiftUI" not "SwiftUI Framework", "iOS" not "iOS Development"
        - Technical skills only (languages, frameworks, tools, platforms)
        - No soft skills

        Rules for yearsOfExperience:
        - Total professional years in the main field

        Rules for seniority:
        - junior: 0-2 years, mid: 2-5 years, senior: 5+ years
        - Infer from job titles AND years of experience
        - If resume says "3 years iOS development" -> "mid"
        - Return exactly one of: "junior", "mid", "senior"

        Resume:
        \(String(text.prefix(12000)))
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

        struct ProfileResponse: Codable {
            let skills: [String]?
            let yearsOfExperience: Int?
            let seniority: String?
        }
        let parsed = try JSONDecoder().decode(ProfileResponse.self, from: Data(content.utf8))
        return ResumeProfile(
            skills: parsed.skills ?? [],
            yearsExperience: parsed.yearsOfExperience,
            seniority: parsed.seniority
        )
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

    private static let genericSkillTokens: Set<String> = [
        "api", "sql", "rest", "git", "agile", "ci/cd"
    ]

    private static let skillSynonymGroups: [[String]] = [
        ["ux", "user experience", "ux/ui", "ux/ui design"],
        ["ai", "ai tools", "ai design tools", "automation in design"],
        ["design systems", "design system", "design tokens"],
        ["information architecture", "ia"],
        ["prototyping", "prototype", "protopie"],
        ["product design", "visual design", "ux/ui design"],
        ["user research", "user-centred design", "user-centered design", "testing"],
        ["b2b saas", "saas"],
        ["cross-functional teams", "cross functional"],
        ["creative software", "design tools"],
        ["lean experiments", "lean", "experiments"],
        ["entrepreneurial spirit", "entrepreneurial"],
        ["swift", "swiftui", "ios"],
        ["figma", "design tools"]
    ]

    private func normalizedSkill(_ skill: String) -> String {
        skill.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func synonymKeys(for skill: String) -> Set<String> {
        let norm = normalizedSkill(skill)
        var keys: Set<String> = [norm]
        for group in Self.skillSynonymGroups {
            let hit = group.contains { token in
                norm == token || norm.contains(token) || token.contains(norm)
            }
            if hit {
                keys.formUnion(group)
            }
        }
        return keys
    }

    private func skillsMatch(_ a: String, _ b: String) -> Bool {
        let al = normalizedSkill(a)
        let bl = normalizedSkill(b)
        guard !al.isEmpty, !bl.isEmpty else { return false }
        if al == bl { return true }

        let aGeneric = Self.genericSkillTokens.contains(al)
        let bGeneric = Self.genericSkillTokens.contains(bl)
        if aGeneric || bGeneric { return false }

        let aKeys = synonymKeys(for: a)
        let bKeys = synonymKeys(for: b)
        if !aKeys.isDisjoint(with: bKeys) { return true }

        let minSubstringLength = 3
        if al.count >= minSubstringLength, bl.count >= minSubstringLength {
            if al.contains(bl) || bl.contains(al) { return true }
        }
        return false
    }

    func matchedJobSkills(resumeSkills: [String], jobSkills: [String]) -> [String] {
        jobSkills.filter { jobSkill in
            resumeSkills.contains { skillsMatch($0, jobSkill) }
        }
    }

    func calculateSkillOverlap(resumeSkills: [String], jobSkills: [String]) -> Double {
        guard !jobSkills.isEmpty else { return 0 }
        let matched = matchedJobSkills(resumeSkills: resumeSkills, jobSkills: jobSkills).count
        return Double(matched) / Double(jobSkills.count)
    }

    func buildMatchBreakdown(
        embeddingScore: Double,
        skillOverlap: Double,
        seniorityFit: Double,
        hasJobSkills: Bool,
        matchedSkillsCount: Int,
        totalJobSkillsCount: Int
    ) -> MatchBreakdown {
        let overall = calculateHybridScore(
            embeddingScore: embeddingScore,
            skillOverlap: skillOverlap,
            seniorityFit: seniorityFit,
            hasJobSkills: hasJobSkills
        )
        let experienceDisplay = max(0, min(1, embeddingScore))
        return MatchBreakdown(
            overallScore: overall,
            experienceScore: experienceDisplay,
            skillsCoverage: skillOverlap,
            levelFit: seniorityFit,
            matchedSkillsCount: matchedSkillsCount,
            totalJobSkillsCount: totalJobSkillsCount
        )
    }

    func calculateSeniorityFit(resumeSeniority: String?, resumeYears: Int?, jobDifficulty: String?) -> Double {
        guard let job = jobDifficulty?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !job.isEmpty,
              let res = resumeSeniority?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !res.isEmpty
        else { return 0.5 }

        let matrix: [String: [String: Double]] = [
            "junior": ["junior": 1.0, "mid": 0.95, "senior": 0.85],
            "mid": ["junior": 0.70, "mid": 1.0, "senior": 0.95],
            "senior": ["junior": 0.40, "mid": 0.75, "senior": 1.0]
        ]
        var fit = matrix[job]?[res] ?? 1.0
        if job == "senior", let years = resumeYears, years < 4 {
            fit *= 0.85
        }
        return fit
    }

    private static let skillOverlapSeniorityThreshold = 0.25
    private static let skillOverlapLowCapThreshold = 0.15
    private static let lowOverlapBaseCap = 0.32

    func calculateHybridScore(
        embeddingScore: Double,
        skillOverlap: Double,
        seniorityFit: Double,
        hasJobSkills: Bool
    ) -> Double {
        let effectiveSeniority: Double
        var base: Double

        if hasJobSkills {
            if skillOverlap < Self.skillOverlapSeniorityThreshold {
                effectiveSeniority = 0
            } else {
                effectiveSeniority = 0.15 * seniorityFit
            }
            base = 0.40 * embeddingScore + 0.45 * skillOverlap + effectiveSeniority
        } else {
            base = 0.70 * embeddingScore + 0.10 * seniorityFit
        }

        if hasJobSkills && skillOverlap < Self.skillOverlapSeniorityThreshold && embeddingScore < 0.55 {
            base *= 0.70
        }

        if hasJobSkills && skillOverlap < Self.skillOverlapLowCapThreshold {
            base = min(base, Self.lowOverlapBaseCap)
        }

        let lowSkillOverlap = hasJobSkills && skillOverlap < Self.skillOverlapSeniorityThreshold
        return calibrate(base, lowSkillOverlap: lowSkillOverlap)
    }

    private func calibrate(_ base: Double, lowSkillOverlap: Bool) -> Double {
        let display: Double
        if lowSkillOverlap {
            display = base * 0.85
        } else if base < 0.52 {
            display = 0.35 + base * 0.65
        } else {
            display = 0.35 + base * 0.90
        }
        return min(0.95, max(0.0, display))
    }
    
    func generateInsights(jobs: [Job]) async throws -> JobInsights {
        guard !jobs.isEmpty else { return JobInsights(summary: "Add more jobs to get insights.") }
        
        // Разделяем exploring и активные
        let exploringJobs = jobs.filter { $0.status == .exploring }
        let activeJobs = jobs.filter { $0.status != .exploring }
        
        let totalJobs = jobs.count
        let totalActive = activeJobs.count
        let avgScore = activeJobs.compactMap { $0.matchScore }.reduce(0, +) / Double(max(activeJobs.compactMap { $0.matchScore }.count, 1))
        
        let statusCounts = Dictionary(grouping: activeJobs, by: { $0.status })
            .mapValues { $0.count }
        
        let allSkills = activeJobs.flatMap { $0.skills }
        let skillFrequency = Dictionary(grouping: allSkills, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(15)
            .map { "\($0.key) (\($0.value))" }
            .joined(separator: ", ")
        
        let topMatches = activeJobs
            .filter { $0.matchScore != nil }
            .sorted { ($0.matchScore ?? 0) > ($1.matchScore ?? 0) }
            .prefix(3)
            .map { "\($0.title ?? "Unknown") at \($0.company ?? "Unknown") — \(Int(($0.matchScore ?? 0) * 100))%" }
            .joined(separator: "; ")
        
        let interviewJobs = activeJobs.filter { $0.status == .interview }
            .map { "\($0.title ?? "Unknown") at \($0.company ?? "Unknown") — \(Int(($0.matchScore ?? 0) * 100))% match" }
            .joined(separator: "; ")
        
        let rejectedJobs = activeJobs.filter { $0.status == .rejected }
            .map { "\($0.title ?? "Unknown") — \(Int(($0.matchScore ?? 0) * 100))% match" }
            .joined(separator: "; ")
        
        let prompt = """
        You are a career coach analyzing job search data. Be concise and actionable.

        Data:
        - Total jobs saved: \(totalJobs) (\(exploringJobs.count) exploring, \(totalActive) applied/in-progress)
        - Average match score (applied jobs): \(Int(avgScore * 100))%
        - Applied: \(statusCounts[.applied] ?? 0), Interviews: \(statusCounts[.interview] ?? 0), Rejected: \(statusCounts[.rejected] ?? 0), Offers: \(statusCounts[.offer] ?? 0)
        - Top matching roles (applied): \(topMatches.isEmpty ? "none yet" : topMatches)
        - Interviews received: \(interviewJobs.isEmpty ? "none yet" : interviewJobs)
        - Rejections: \(rejectedJobs.isEmpty ? "none yet" : rejectedJobs)
        - Most required skills across applied jobs: \(skillFrequency.isEmpty ? "none yet" : skillFrequency)

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
        let content = response.choices.first?.message.content ?? "{}"
        guard let jsonData = content.data(using: .utf8) else {
            return JobInsights(summary: nil)
        }
        return try JSONDecoder().decode(JobInsights.self, from: jsonData)
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
    
    func fetchJobFromURL(_ url: String) async throws -> (title: String?, company: String?, location: String?, description: String?, companyLogo: String?) {
        let functionURL = "\(Secrets.supabaseURL)/functions/v1/fetch-job"
        
        var request = URLRequest(url: URL(string: functionURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.supabaseKey, forHTTPHeaderField: "apikey")
        
        let body = ["url": url]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        struct JobResponse: Codable {
            let title: String?
            let company: String?
            let location: String?
            let description: String?
            let companyLogo: String?
            
            enum CodingKeys: String, CodingKey {
                case title, company, location, description
                case companyLogo = "companyLogo"
            }
        }
        
        let response = try JSONDecoder().decode(JobResponse.self, from: data)
        return (response.title, response.company, response.location, response.description, response.companyLogo)
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

struct ResumeProfile {
    let skills: [String]
    let yearsExperience: Int?
    let seniority: String?
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
