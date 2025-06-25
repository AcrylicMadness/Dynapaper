//
//  DecorativeView.swift
//  Dynapaper
//
//  Created by Acrylic M on 26.06.2025.
//

import SwiftUI

struct DecorativeView: View {
    
    enum Style: String {
        case sun = "sun.max.fill"
        case moon = "moon.fill"
    }
    
    let style: Style
    
    @State
    var geometry: GeometryProxy
    

    var body: some View {
        Image(systemName: style.rawValue)
            
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: imageSize.width,
                height: imageSize.height
            )
            .position(imagePosition)
            .opacity(0.1)
            .fontWeight(.regular)
    }
    
    private var imageSize: CGSize {
        switch style {
        case .sun:
            return CGSize(
                width: geometry.size.width / 1.4,
                height: geometry.size.height / 1.4
            )
        case .moon:
            return CGSize(
                width: geometry.size.width / 1.9,
                height: geometry.size.height / 1.9
            )
        }
    }
    
    private var imagePosition: CGPoint {
        switch style {
        case .sun:
            return CGPoint(
                x: geometry.size.width - 40,
                y: 50
            )
        case .moon:
            return CGPoint(
                x: 100,
                y: geometry.size.height - 70
            )
        }
    }
    
}

#Preview {
    ZStack {
        GeometryReader { proxy in
            DecorativeView(style: .moon, geometry: proxy)
            DecorativeView(style: .sun, geometry: proxy)
        }
    }
    .frame(width: 800, height: 600)
}
