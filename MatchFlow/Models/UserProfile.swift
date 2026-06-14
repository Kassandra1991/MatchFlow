import Foundation

struct UserProfile: Codable {
    var id: UUID
    var email: String
    var fullName: String?
    var headline: String?
    var importantInCompany: String?
    var workStyle: String?
    var careerGoals: String?
    var coverLetterTone: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case headline
        case importantInCompany = "important_in_company"
        case workStyle = "work_style"
        case careerGoals = "career_goals"
        case coverLetterTone = "cover_letter_tone"
    }
}

extension UserProfile {
    var displayFullName: String {
        guard let name = fullName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return "Add your name"
        }
        return name
    }

    var profileSubtitle: String? {
        let parts = [headline, workStyle]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: " • ")
    }
}

enum CoverLetterTone: String, CaseIterable {
    case formal = "formal"
    case friendly = "friendly"
    case concise = "concise"
    
    var label: String {
        switch self {
        case .formal: return "Formal"
        case .friendly: return "Friendly"
        case .concise: return "Concise"
        }
    }
}
