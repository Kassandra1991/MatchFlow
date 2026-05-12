import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile? = nil
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var isEditing = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    
    // Edit fields
    @Published var fullName = ""
    @Published var headline = ""
    @Published var importantInCompany = ""
    @Published var workStyle = ""
    @Published var careerGoals = ""
    @Published var coverLetterTone = "friendly"
    
    private let profileService = ProfileService.shared
    
    func fetchProfile(userId: UUID) async {
        isLoading = true
        do {
            profile = try await profileService.fetchProfile(userId: userId)
            if let profile {
                populateFields(from: profile)
            } else {
                isEditing = true // первый раз — сразу в режим редактирования
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func saveProfile(userId: UUID) async {
        isSaving = true
        do {
            let updated = UserProfile(
                id: userId,
                email: profile?.email ?? "",
                fullName: fullName,
                headline: headline,
                importantInCompany: importantInCompany,
                workStyle: workStyle,
                careerGoals: careerGoals,
                coverLetterTone: coverLetterTone
            )
            try await profileService.saveProfile(profile: updated)
            profile = updated
            isEditing = false
            successMessage = "Profile saved!"
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
    
    func startEditing() {
        if let profile {
            populateFields(from: profile)
        }
        isEditing = true
    }
    
    private func populateFields(from profile: UserProfile) {
        fullName = profile.fullName ?? ""
        headline = profile.headline ?? ""
        importantInCompany = profile.importantInCompany ?? ""
        workStyle = profile.workStyle ?? ""
        careerGoals = profile.careerGoals ?? ""
        coverLetterTone = profile.coverLetterTone ?? "friendly"
    }
}
