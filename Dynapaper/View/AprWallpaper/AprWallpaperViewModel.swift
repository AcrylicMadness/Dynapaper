//
//  AprWallpaperViewModel.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import SwiftUI

@MainActor
class AprWallpaperViewModel: ObservableObject {
    
    enum AprVMError: Error {
        case failedToGetMainScreen
    }
    
    // MARK: - Properties
    
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
    var setWallpaperOnComplete: Bool = false
    
    @Published
    private(set) var readyForHeic: Bool = false
    
    @Published
    private(set) var isProcessing: Bool = false
    
    @Published
    private(set) var displayError: Error?
    
    private let proccessor = AprWallpaperProccessor()
    private var encodeTask: Task<Data, any Error>?
    
    // MARK: Interface
    func loadImages(
        fromUrls urls: [URL],
        priorityMode: AprWallpaperProccessor.Mode = .light
    ) {
        var modes = AprWallpaperProccessor.Mode.allCases
        if let priorityIndex = modes.firstIndex(of: priorityMode) {
            modes.remove(at: priorityIndex)
            modes.insert(priorityMode, at: 0)
        }
        
        for (index, mode) in modes.enumerated() {
            if urls.indices.contains(index) {
                do {
                    let nsImage = try proccessor.getNsImage(
                        fromUrl: urls[index],
                        forMode: mode,
                        shouldLoad: false
                    )
                    let image = Image(nsImage: nsImage)
                    withAnimation(.bouncy(duration: 0.55)) {
                        if mode == .light {
                            lightImage = image
                        } else {
                            darkImage = image
                        }
                    }
                } catch {
                    setError(error)
                }
            }
        }
    }
    
    func swapImages() {
        swap(&lightImage, &darkImage)
    }
    
    func makeHeic() async {
        defer {
            setProccessing(false)
        }
        
        encodeTask?.cancel()
        encodeTask = Task.detached { [weak self] in
            guard let self else { throw DynapaperError.exportCancelled }
            return try await self.proccessor.makeHeif()
        }
        
        setProccessing(true)
        
        do {
            let data = try await runEncodeTask()
            guard
                let destinationUrl = await OpenSavePanel.showSavePanel()
            else {
                throw DynapaperError.exportCancelled
            }
            try data.write(to: destinationUrl)
            if setWallpaperOnComplete {
                try setDesktopWallpaper(url: destinationUrl)
            }
        } catch {
            if !(error as? DynapaperError == DynapaperError.exportCancelled) {
                displayError = error
            }
        }
    }
    
    func cancelEncoding() {
        encodeTask?.cancel()
        setProccessing(false)
    }
    
    func setError(_ error: Error?) {
        withAnimation(.bouncy(duration: 0.3)) {
            self.displayError = error
        }
    }
    
    // MARK: Private Logic
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
    
    private func setDesktopWallpaper(url: URL) throws {
        guard let screen = NSScreen.main else {
            throw AprVMError.failedToGetMainScreen
        }
        try NSWorkspace.shared.setDesktopImageURL(
            url,
            for: screen,
            options: [:]
        )
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
    
    private func setProccessing(_ priccessing: Bool) {
        withAnimation(.easeIn(duration: 0.1)) {
            isProcessing = priccessing
        }
    }
}
