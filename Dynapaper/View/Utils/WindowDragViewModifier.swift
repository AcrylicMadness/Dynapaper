//
//  WindowDragViewModifier.swift
//  Dynapaper
//
//  Created by Acrylic M on 16.07.2025.
//

import SwiftUI

struct WindowDragViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            content
                .gesture(WindowDragGesture())
        } else {
            content
        }
    }
}

extension View {
    func windowDrag() -> some View {
        modifier(WindowDragViewModifier())
    }
}
