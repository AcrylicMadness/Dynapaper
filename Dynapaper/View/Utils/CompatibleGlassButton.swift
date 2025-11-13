//
//  CompatibleGlassButton.swift
//  Dynapaper
//
//  Created by Acrylic M. on 13.11.2025.
//

import SwiftUI

enum CompatibleGlass {
    case clear
    case identity
}

struct CompatibleGlassEffect<T: PrimitiveButtonStyle>: ViewModifier {
    
    var isProminent: Bool = false
    var fallbackButtonStyle: T
    
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            if isProminent {
                content
                    .buttonStyle(.glassProminent)
            } else {
                content
                    .buttonStyle(.glass)
            }
        } else {
            content
                .buttonStyle(fallbackButtonStyle)
        }
    }
}

extension Button {
    func compatibleGlassStyle<T: PrimitiveButtonStyle>(
        isProminent: Bool,
        fallbackStyle: T
    ) -> some View {
        modifier(
            CompatibleGlassEffect(
                isProminent: isProminent,
                fallbackButtonStyle: fallbackStyle
            )
        )
    }
}
