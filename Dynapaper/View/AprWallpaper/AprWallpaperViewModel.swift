//
//  AprWallpaperViewModel.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import SwiftUI

@MainActor
class AprWallpaperViewModel: ObservableObject {
    
    @Published
    var lightImage: Image? {
        didSet {
            loadImage(forMode: .light)
        }
    }
    
    @Published
    var darkImage: Image? {
        didSet {
            loadImage(forMode: .dark)
        }
    }
    
    @Published
    private(set) var displayError: Error?
    
    private let proccessor = AprWallpaperProccessor()
    
    private func loadImage(forMode mode: AprWallpaperProccessor.Mode) {
        if let imageToLoad = (mode == .light ? lightImage : darkImage) {
            guard let nsImage = ImageRenderer(content: imageToLoad).nsImage else {
                displayError = DynapaperError.nilImageData
                clearImage(forMode: mode)
                return
            }
            proccessor.loadWallpaper(fromImage: nsImage, forMode: mode)
        }
    }
    
    private func clearImage(forMode mode: AprWallpaperProccessor.Mode) {
        switch mode {
        case .light:
            lightImage = nil
        case .dark:
            darkImage = nil
        }
    }
    
    func setError(_ error: Error?) {
        withAnimation {
            self.displayError = error
        }
    }
}
