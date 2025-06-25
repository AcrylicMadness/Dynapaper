//
//  DynapaperApp.swift
//  Dynapaper
//
//  Created by Acrylic M on 11.06.2025.
//

import SwiftUI

@main
struct DynapaperApp: App {
    
    private let windowSize: CGSize = CGSize(width: 800, height: 500)
    
    var body: some Scene {
        WindowGroup {
            if #available(macOS 15, *) {
                AprWallpaperView()
                    .containerBackground(
                        .thinMaterial, for: .window
                    )
                    .frame(
                        minWidth: windowSize.width,
                        maxWidth: windowSize.width,
                        minHeight: windowSize.height,
                        maxHeight: windowSize.height
                    )
            } else {
                AprWallpaperView()
                    .frame(
                        minWidth: windowSize.width,
                        maxWidth: windowSize.width,
                        minHeight: windowSize.height,
                        maxHeight: windowSize.height
                    )
            }
            
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
