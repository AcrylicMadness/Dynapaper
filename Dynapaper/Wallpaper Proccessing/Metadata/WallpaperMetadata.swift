//
//  WallpaperMetadata.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import Foundation
import ImageIO

protocol WallpaperMetadata {
    associatedtype Payload: Encodable
    
    var xmlns: String { get }
    var prefix: String { get }
    var path: String { get }
    
    var name: WallpaperType { get }
    var payload: Payload { get }
    
    var cgMetadataTag: CGImageMetadataTag { get throws }
    var cgMetadata: CGImageMetadata { get throws }
}

extension WallpaperMetadata {
    var xmlns: String {
        "http://ns.apple.com/namespace/1.0/"
    }
    
    var prefix: String {
        "apple_desktop"
    }
    
    var path: String {
        "xmp:\(name.rawValue)"
    }
    
    var cgMetadataTag: CGImageMetadataTag {
        get throws {
            guard
                let metadata = try? PropertyListEncoder().encode(payload).base64EncodedString() as CFString
            else {
                throw WallpaperMetadataError.encodingFailed
            }
            guard let tag = CGImageMetadataTagCreate(
                xmlns as CFString,
                prefix as CFString,
                name.rawValue as CFString,
                .string,
                metadata
            ) else {
                throw WallpaperMetadataError.initializingFailed
            }
            return tag
        }
    }
    
    var cgMetadata: CGImageMetadata {
        get throws {
            let imageMetadata = CGImageMetadataCreateMutable()
            let tag = try cgMetadataTag
            CGImageMetadataSetTagWithPath(imageMetadata, nil, path as CFString, tag)
            return imageMetadata as CGImageMetadata
        }
    }
}

enum WallpaperMetadataError: Error {
    case encodingFailed
    case initializingFailed
}
