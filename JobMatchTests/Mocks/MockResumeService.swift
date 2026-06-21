//
//  MockResumeService.swift
//  JobMatchTests
//

import Foundation
@testable import MatchFlow

final class MockResumeService: ResumeServiceProtocol {
    var defaultResume: Resume?

    func saveResume(userId: UUID, title: String, rawText: String, isDefault: Bool) async throws -> Resume {
        let resume = Resume(
            id: UUID(),
            userId: userId,
            title: title,
            rawText: rawText,
            skillsRaw: nil,
            yearsExperience: nil,
            seniority: nil,
            isDefault: isDefault,
            createdAt: Date()
        )
        defaultResume = resume
        return resume
    }

    func fetchResumes(userId: UUID) async throws -> [Resume] {
        defaultResume.map { [$0] } ?? []
    }

    func fetchDefaultResume(userId: UUID) async throws -> Resume? {
        defaultResume
    }

    func setDefault(resumeId: UUID, userId: UUID) async throws {}

    func deleteResume(resumeId: UUID) async throws {
        defaultResume = nil
    }

    func extractTextFromPDF(url: URL) -> String { "" }
}
