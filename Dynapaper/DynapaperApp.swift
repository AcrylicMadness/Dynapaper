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
    
    @StateObject
    private var aprWallpaperViewModel = AprWallpaperViewModel()
    
    var body: some Scene {
        Window("Dynapaper", id: "dynapaper-window") {
            if #available(macOS 15, *) {
                AprWallpaperView(viewModel: aprWallpaperViewModel)
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
        // TODO: Refactor menu bar commands
        .commands {
            CommandGroup(replacing: .saveItem) {
                Button(
                    "MENU_FILE_SAVE",
                    action: {
                        Task {
                            await aprWallpaperViewModel.makeHeic()
                        }
                    }
                )
                .keyboardShortcut("S", modifiers: .command)
                .disabled(!aprWallpaperViewModel.readyForHeic)
            }
            CommandGroup(before: .newItem) {
                Button(
                    "MENU_FILE_IMPORT",
                    action: {
                        Task {
                            aprWallpaperViewModel.loadImages(
                                fromUrls: await OpenSavePanel.showOpenPanel()
                            )
                        }
                    }
                )
                .keyboardShortcut("A", modifiers: .command)
            }
            CommandGroup(replacing: .undoRedo) {
                Button(
                    "MENU_EDIT_CLEAR",
                    action: {
                        withAnimation {
                            aprWallpaperViewModel.darkImage = nil
                            aprWallpaperViewModel.lightImage = nil
                        }
                    }
                )
                .keyboardShortcut("K", modifiers: .command)
                Button(
                    "MENU_EDIT_SWAP",
                    action: {
                        withAnimation {
                            aprWallpaperViewModel.swapImages()
                        }
                    }
                )
                .keyboardShortcut("E", modifiers: .command)
            }
        }
    }
}
