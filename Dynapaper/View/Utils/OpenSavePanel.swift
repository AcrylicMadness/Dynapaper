//
//  SavePanel.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import SwiftUI

struct OpenSavePanel {
    
    static func showSavePanel() -> URL? {
        let savePanel = NSSavePanel()
//        savePanel.allowedFileTypes = ["heic"]
        savePanel.allowedContentTypes = [.heic]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = true
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your text"
        savePanel.message = "Choose a folder and a name to store your text."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = "Dynamic Wallpaper"
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
    
}
