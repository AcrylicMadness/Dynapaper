//
//  ImageField.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import SwiftUI

struct ImageField: View {
    
    @Binding
    var image: Image?
    
    @State
    private var isTargeted: Bool = false
    
    var onLoadError: (Error) -> Void
    var didSelectImageUrls: ([URL]) -> Void
    
    private let animation: Animation = .bouncy(duration: 0.55)
    
    enum Error: Swift.Error {
        case imageImportFailed
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .background {
                if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.blurReplace)
                } else {
                    Color.secondary.opacity(0.4)
                }
            }
            .overlay {
                overlay
            }
            .cornerRadius(8)
            .dropDestination(
                for: Image.self,
                action: { images, _ in
                    if let draggedImage = images.first {
                        withAnimation(animation) {
                            image = draggedImage
                        }
                        return true
                    }
                    onLoadError(Error.imageImportFailed)
                    return false
                },
                isTargeted: { targeted in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTargeted = targeted
                    }
                }
            )
            .opacity(isTargeted ? 0.5 : 1)
    }
    
    @ViewBuilder
    var overlay: some View {
        let fullSize = image == nil
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                if !fullSize {
                    deleteButton
                    Spacer()
                }
                selectButton(fullSize: fullSize, proxy: proxy)
            }
            .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    var deleteButton: some View {
        Button(
            action: {
                withAnimation(animation) {
                    image = nil
                }
            },
            label: {
                if #available(macOS 26, *) {
                    Image(systemName: "trash")
                } else {
                    Image(systemName: "trash")
                        .symbolVariant(.fill)
                        .padding(4)
                        .background(.regularMaterial)
                        .cornerRadius(6)
                }
            }
        )
        .compatibleGlassStyle(
            isProminent: false,
            fallbackStyle: PlainButtonStyle()
        )
        .padding(4)
        .transition(.move(edge: .leading))
    }
    
    @ViewBuilder
    func selectButton(fullSize: Bool, proxy: GeometryProxy) -> some View {
        Button(
            action: {
                Task {
                    didSelectImageUrls(await OpenSavePanel.showOpenPanel())
                }
            },
            label: {
                if #available(macOS 26, *) {
                    selectButtonLabel(fullSize: fullSize, proxy: proxy)
                        .glassEffect(.regular, in: .rect(cornerRadius: 8))
                } else {
                    selectButtonLabel(fullSize: fullSize, proxy: proxy)
                        .background(.regularMaterial)
                }
            }
        )
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func selectButtonLabel(fullSize: Bool, proxy: GeometryProxy) -> some View {
        HStack {
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Image(systemName: "plus")
                    .symbolVariant(.circle.fill)
                Text("DRAG_OR_SELECT_IMAGE")
            }
            .font(.caption2)
            Spacer()
        }
        .frame(minHeight: fullSize ? proxy.size.height : 0)
        .padding(4)
        .background {
            Color(nsColor: .secondarySystemFill)
                .opacity(fullSize ? 1 : 0)
        }
    }
}

#Preview {
    ImageField(
        image: .constant(
            nil
        ),
        onLoadError: { _ in
        },
        didSelectImageUrls: { _ in
            
        }
    )
    .frame(width: 200, height: 120)
}
