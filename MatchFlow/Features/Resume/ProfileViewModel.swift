import Foundation
import Combine

struct ProfileEditFields: Equatable {
    let fullName: String
    let headline: String
    let importantInCompany: String
    let workStyle: String
}

@MainActor
class ProfileViewModel: ObservableObject {
    static let workStyleOptions = ["Hybrid", "Remote"]

    @Published var profile: UserProfile? = nil
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var isEditing = false
    @Published var errorMessage = ""

    @Published var fullName = ""
    @Published var headline = ""
    @Published var importantInCompany = ""
    @Published var workStyle = ""
    @Published var careerGoals = ""
    @Published var coverLetterTone = "friendly"

    private var editBaseline: ProfileEditFields?
    private let profileService: ProfileServiceProtocol

    var displayWorkStyle: String {
        Self.normalizedWorkStyle(workStyle)
    }

    var hasUnsavedChanges: Bool {
        guard let editBaseline else { return false }
        return currentEditFields != editBaseline
    }

    var canSave: Bool {
        hasUnsavedChanges
            && !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isSaving
    }

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
    }

    func fetchProfile(userId: UUID) async {
        isLoading = true
        do {
            profile = try await profileService.fetchProfile(userId: userId)
            if let profile {
                populateFields(from: profile)
            } else {
                isEditing = true
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
                workStyle: Self.normalizedWorkStyle(workStyle),
                careerGoals: careerGoals,
                coverLetterTone: coverLetterTone
            )
            try await profileService.saveProfile(profile: updated)
            profile = updated
            populateFields(from: updated)
            captureEditBaseline()
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    func startEditing() {
        if let profile {
            populateFields(from: profile)
        }
        captureEditBaseline()
        isEditing = true
    }

    func captureEditBaseline() {
        editBaseline = currentEditFields
    }

    private func populateFields(from profile: UserProfile) {
        fullName = profile.fullName ?? ""
        headline = profile.headline ?? ""
        importantInCompany = profile.importantInCompany ?? ""
        workStyle = Self.normalizedWorkStyle(profile.workStyle ?? "")
        careerGoals = profile.careerGoals ?? ""
        coverLetterTone = profile.coverLetterTone ?? "friendly"
    }

    private var currentEditFields: ProfileEditFields {
        ProfileEditFields(
            fullName: trimmed(fullName),
            headline: trimmed(headline),
            importantInCompany: trimmed(importantInCompany),
            workStyle: Self.normalizedWorkStyle(workStyle)
        )
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedWorkStyle(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return workStyleOptions[0]
        }
        return trimmed
    }
}
