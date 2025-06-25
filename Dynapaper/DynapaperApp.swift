//
//  DynapaperApp.swift
//  Dynapaper
//
//  Created by Acrylic M on 11.06.2025.
//

import SwiftUI

@main
struct DynapaperApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(macOS 15, *) {
                AprWallpaperView()
                    .containerBackground(
                        .thinMaterial, for: .window
                    )
            } else {
                AprWallpaperView()
            }
            
        }
        .windowStyle(.hiddenTitleBar)
    }
}
