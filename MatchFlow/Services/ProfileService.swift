import Foundation
import Supabase

class ProfileService {
    static let shared = ProfileService()
    
    func fetchProfile(userId: UUID) async throws -> UserProfile? {
        let profiles: [UserProfile] = try await supabase
            .from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        return profiles.first
    }
    
    func saveProfile(profile: UserProfile) async throws {
        try await supabase
            .from("users")
            .update([
                "full_name": profile.fullName ?? "",
                "headline": profile.headline ?? "",
                "important_in_company": profile.importantInCompany ?? "",
                "work_style": profile.workStyle ?? "",
                "career_goals": profile.careerGoals ?? "",
                "cover_letter_tone": profile.coverLetterTone ?? "friendly"
            ])
            .eq("id", value: profile.id.uuidString)
            .execute()
    }
}
