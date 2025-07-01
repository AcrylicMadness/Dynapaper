//
//  AprWallpaperView.swift
//  Dynapaper
//
//  Created by Acrylic M on 25.06.2025.
//

import SwiftUI

struct AprWallpaperView: View {
    
    @StateObject
    var viewModel = AprWallpaperViewModel()
    
    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        ZStack {
            VStack {
                Text("Dynapaper")
                    .font(.system(size: 50))
                Spacer()
                HStack {
                    Spacer()
                    imageField(
                        for: $viewModel.darkImage,
                        title: "DARK_MODE_WALLPAPER",
                        mode: .dark
                    )
                    
                    Spacer()
                    Button("SWAP_IMAGES", action: {
                        withAnimation {
                            viewModel.swapImages()
                        }
                    })
                    Spacer()
                    imageField(
                        for: $viewModel.lightImage,
                        title: "LIGHT_MODE_WALLPAPER",
                        mode: .light
                    )
                    .frame(width: 200, height: 120)
                    Spacer()
                }
                Spacer()
                encodeButtonContainer
                Spacer()
            }
            .padding(40)
            errorView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    darkImageBackground(withGeometry: geometry)
                    lightImageBackground(withGeometry: geometry)
                }
                .ignoresSafeArea()
            }
        }
    }
    
    @ViewBuilder
    var encodeButtonContainer: some View {
        // TODO: Make this look nice
        if viewModel.isProcessing {
            Button("CANCEL_ENCODING", action: {
                viewModel.cancelEncoding()
            })
            HStack {
                ProgressView()
                Text("Making heic")
            }
        } else {
            VStack {
                Toggle(
                    "SET_ON_COMPLETE",
                    isOn: $viewModel.setWallpaperOnComplete
                )
                Button("MAKE_HEIC", action: {
                    Task {
                        await viewModel.makeHeic()
                    }
                })
                .disabled(!viewModel.readyForHeic)
            }
        }
    }
    
    @ViewBuilder
    func imageField(
        for image: Binding<Image?>,
        title: LocalizedStringKey,
        mode: AprWallpaperProccessor.Mode
    ) -> some View {
        VStack {
            Text(title)
            ImageField(
                image: image,
                onLoadError: { error in
                    viewModel.setError(error)
                },
                didSelectImageUrls: { urls in
                    viewModel.loadImages(
                        fromUrls: urls,
                        priorityMode: mode
                    )
                }
            )
            .frame(width: 200, height: 120)
        }
    }
    
    @ViewBuilder
    func darkImageBackground(
        withGeometry geometry: GeometryProxy
    ) -> some View {
        Rectangle()
            .fill(Color.clear)
            .background {
                if colorScheme == .light {
                    Color.secondary.opacity(0.1)
                }
                
                if let darkImage = viewModel.darkImage {
                    darkImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(.ultraThinMaterial)
                        .transition(.opacity)
                } else {
                    DecorativeView(style: .moon, geometry: geometry)
                        .transition(.blurReplace)
                }
            }
            .reverseMask {
                circleMask(forGeometry: geometry)
                    .blendMode(.destinationOut)
            }
    }
    
    @ViewBuilder
    func lightImageBackground(
        withGeometry geometry: GeometryProxy
    ) -> some View {
        Rectangle()
            .fill(Color.clear)
            .background {
                if colorScheme == .dark {
                    Color.secondary.opacity(0.1)
                }
                if let lightImage = viewModel.lightImage {
                    lightImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(.ultraThinMaterial)
                        .transition(.opacity)
                } else {
                    DecorativeView(style: .sun, geometry: geometry)
                        .transition(.blurReplace)
                }
            }
            .mask {
                circleMask(forGeometry: geometry)
            }
    }
    
    @ViewBuilder
    func circleMask(
        forGeometry geometry: GeometryProxy
    ) -> some View {
        Circle()
            .fill(Color.black)
            .frame(width: geometry.size.width * 2, height: geometry.size.width * 2)
            .position(x: geometry.size.width * 1.5, y: geometry.size.height / 2)
    }
    
    // TODO: Move this to view modifier
    @ViewBuilder
    var errorView: some View {
        VStack(alignment: .center) {
            Spacer()
            if let error = viewModel.displayError {
                HStack(alignment: .center) {
                    Image(systemName: "xmark.app.fill")
                        .foregroundStyle(.red)
                    Text(error.localizedDescription)
                        .font(.caption2)
                    Spacer()
                    Button("CLOSE_ERROR") {
                        viewModel.setError(nil)
                    }
                }
                .padding(6)
                .background {
                    ZStack {
                        Color(nsColor: .windowBackgroundColor)
                        Color.red.opacity(0.2)
                    }
                }
                .cornerRadius(8)
                .transition(.move(edge: .bottom).combined(with: .blurReplace))
            }
            
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topTrailing
        )
        .padding()
    }
}

#Preview {
    AprWallpaperView()
        .frame(width: 800, height: 600)
}

