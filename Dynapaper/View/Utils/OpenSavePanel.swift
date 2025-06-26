//
//  SavePanel.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import SwiftUI

struct OpenSavePanel {
    
    @MainActor
    static func showSavePanel(nameSuggestion: String? = nil) async -> URL? {
        let savePanel = NSSavePanel()
        
        savePanel.allowedContentTypes = [.heic]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = true
        savePanel.allowsOtherFileTypes = false
        savePanel.title = String(localized: "WALLPAPER_SAVE_TITLE")
        savePanel.message = String(localized: "WALLPAPER_SAVE_MESSAGE")
        savePanel.nameFieldLabel = String(localized: "WALLPAPER_SAVE_FIELD_LABEL")
        savePanel.nameFieldStringValue = nameSuggestion ?? String(localized: "WALLPAPER_SAVE_FILENAME")
        
        let response = await savePanel.beginSheetModal(for: NSApplication.shared.mainWindow!)
        return response == .OK ? savePanel.url : nil
    }
    
    @MainActor
    static func showOpenPanel() async -> [URL] {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = await openPanel.beginSheetModal(for: NSApplication.shared.mainWindow!)
        return response == .OK ? openPanel.urls : []
    }
}
