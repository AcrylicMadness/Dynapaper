//
//  AprWallpaperMetadata.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import Foundation

struct AprWallpaperMetadata: WallpaperMetadata {
    let name: WallpaperType = .apr
    let payload: Payload = Payload()
    
    struct Payload: Encodable {
        let d: Int = 1
        let l: Int = 0
    }
}
