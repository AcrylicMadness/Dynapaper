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
    var readyForHeic: Bool = false
    
    @Published
    var isProcessing: Bool = false
    
    @Published
    private(set) var displayError: Error?
    
    private let proccessor = AprWallpaperProccessor()
    private var encodeTask: Task<Data, any Error>?
    
    private func loadImage(forMode mode: AprWallpaperProccessor.Mode) {
        defer {
            updateReadyStatus()
        }
        if let imageToLoad = (mode == .light ? lightImage : darkImage) {
            guard let nsImage = ImageRenderer(content: imageToLoad).nsImage else {
                displayError = DynapaperError.nilImageData
                clearImage(forMode: mode)
                return
            }
            proccessor.loadWallpaper(fromImage: nsImage, forMode: mode)
        }
    }
    
    func swapImages() {
        swap(&lightImage, &darkImage)
    }
    
    func makeHeic() async {
        defer {
            isProcessing = false
        }
        
        encodeTask?.cancel()
        encodeTask = Task.detached { [weak self] in
            guard let self else { throw DynapaperError.exportCancelled }
            return try await self.proccessor.makeHeif()
        }
        
        isProcessing = true
        
        do {
            let data = try await runEncodeTask()
            guard !(encodeTask?.isCancelled ?? false) else { return }
            let destinationUrl = OpenSavePanel.showSavePanel()
            if let url = destinationUrl {
                try data.write(to: url)
            }
        } catch {
            if !(error as? DynapaperError == DynapaperError.exportCancelled) {
                displayError = error
            }
        }
    }
    
    func cancelEncoding() {
        encodeTask?.cancel()
        isProcessing = false
    }
    
    private func runEncodeTask() async throws -> Data {
        let result = await encodeTask?.result
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        default:
            throw DynapaperError.exportCancelled
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
    
    private func updateReadyStatus() {
        readyForHeic = lightImage != nil && darkImage != nil
    }
    
    func setError(_ error: Error?) {
        withAnimation {
            self.displayError = error
        }
    }
}
