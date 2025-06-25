//
//  AprWallpaperProccessor.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import AppKit
import Foundation
import ImageIO

class AprWallpaperProccessor {
    var lightImage: NSImage?
    var darkImage: NSImage?
    
    enum Mode: String, CaseIterable {
        case light
        case dark
    }
    
    init(lightImage: NSImage? = nil, darkImage: NSImage? = nil) {
        self.lightImage = lightImage
        self.darkImage = darkImage
    }
    
    func loadWallpaper(
        fromUrl wallpaperUrl: URL,
        forMode mode: Mode
    ) throws {
        let imageData = try Data(contentsOf: wallpaperUrl)
        try loadWallpaper(fromData: imageData, forMode: mode)
    }
    
    func loadWallpaper(
        fromData imageData: Data?,
        forMode mode: Mode
    ) throws {
        guard let imageData, let image = NSImage(data: imageData) else {
            throw DynapaperError.nilImageData
        }
        loadWallpaper(fromImage: image, forMode: mode)
    }
    
    func loadWallpaper(
        fromImage image: NSImage,
        forMode mode: Mode
    ) {
        switch mode {
        case .light:
            lightImage = image
        case .dark:
            darkImage = image
        }
    }
    
    func makeHeif() throws -> Data {
        guard
            let lightImage = lightImage?.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let darkImage = darkImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            throw DynapaperError.imageForModeNotFound
        }
        
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 2, nil)
        else {
            throw DynapaperError.failedToSetupExport
        }

        let metadata = try AprWallpaperMetadata().cgMetadata

        CGImageDestinationAddImageAndMetadata(destination, lightImage, metadata, nil)
        CGImageDestinationAddImage(destination, darkImage, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            throw DynapaperError.failedToExport
        }
        
        return (mutableData as Data)
    }
}

enum DynapaperError: Error {
    case nilImageData
    case imageForModeNotFound
    case badMetadata
    case failedToSetupExport
    case failedToExport
    case exportCancelled
}
