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
