//
//  ShareViewController.swift
//  MatchFlowShare
//
//  Created by Aleksandra Asichka on 10/05/2026.
//

import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractAndSave()
    }
    
    private func extractAndSave() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            close()
            return
        }
        
        // Пробуем получить URL
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, error in
                    if let url = item as? URL {
                        self?.handleURL(url)
                    }
                }
                return
            }
            
            // Если нет URL — берём текст
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] item, error in
                    if let text = item as? String {
                        self?.handleText(text)
                    }
                }
                return
            }
        }
    }
    
    private func handleURL(_ url: URL) {
        // Сохраняем в UserDefaults (shared container)
        let defaults = UserDefaults(suiteName: "group.com.asichka.matchflow")
        defaults?.set(url.absoluteString, forKey: "pendingJobURL")
        defaults?.synchronize()
        
        showConfirmation(message: "Job URL saved! Open MatchFlow to analyze.")
    }
    
    private func handleText(_ text: String) {
        let defaults = UserDefaults(suiteName: "group.com.asichka.matchflow")
        defaults?.set(text, forKey: "pendingJobText")
        defaults?.synchronize()
        
        showConfirmation(message: "Job saved! Open MatchFlow to analyze.")
    }
    
    private func showConfirmation(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "MatchFlow", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.close()
            })
            self.present(alert, animated: true)
        }
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
