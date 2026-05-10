//
//  JobDetailViewModel.swift
//  MatchFlow
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import Foundation
import Combine

@MainActor
class JobDetailViewModel: ObservableObject {
    @Published var selectedStatus: JobStatus = .applied
    @Published var notes: String = ""
    @Published var jobDescription: String = ""
    @Published var analysis: JobAnalysis? = nil
    @Published var isAnalyzing = false
    @Published var errorMessage = ""
    @Published var updatedJob: Job? = nil
    
    func updateStatus(job: Job, status: JobStatus) async {
        do {
            try await JobService.shared.updateStatus(jobId: job.id, status: status)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func analyze(job: Job) async {
        isAnalyzing = true
        do {
            let text = jobDescription.isEmpty ? (job.rawText ?? "") : jobDescription
            let result = try await AIService.shared.analyzeJob(description: text)
            analysis = result
            try await JobService.shared.saveAnalysis(jobId: job.id, analysis: result)
            // Перезагружаем job из базы
            updatedJob = try await JobService.shared.fetchJob(jobId: job.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isAnalyzing = false
    }
}
