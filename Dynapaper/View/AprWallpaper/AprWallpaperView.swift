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
                        title: "DARK_MODE_WALLPAPER"
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
                        title: "LIGHT_MODE_WALLPAPER"
                    )
                    .frame(width: 200, height: 120)
                    Spacer()
                }
                Spacer()
                if viewModel.isProcessing {
                    Button("CANCEL_ENCODING", action: {
                        viewModel.cancelEncoding()
                    })
                    HStack {
                        ProgressView()
                        Text("Making heic")
                    }
                } else {
                    Button("MAKE_HEIC", action: {
                        Task {
                            await viewModel.makeHeic()
                        }
                    })
                    .disabled(!viewModel.readyForHeic)
                }
                if viewModel.isProcessing {
                    
                }
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
    func imageField(
        for image: Binding<Image?>,
        title: LocalizedStringKey
    ) -> some View {
        VStack {
            Text(title)
            ImageField(
                image: image,
                onLoadError: { error in
                    viewModel.setError(error)
                }
            )
            .frame(width: 200, height: 120)
        }
    }
    
    @ViewBuilder
    func darkImageBackground(withGeometry geometry: GeometryProxy) -> some View {
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
                }
            }
            .reverseMask {
                Circle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width * 2, height: geometry.size.width * 2)
                    .position(x: geometry.size.width * 1.5, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
            }
    }
    
    @ViewBuilder
    func lightImageBackground(withGeometry geometry: GeometryProxy) -> some View {
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
                }
            }
            .mask {
                Circle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width * 2, height: geometry.size.width * 2)
                    .position(x: geometry.size.width * 1.5, y: geometry.size.height / 2)
            }
    }
    
    @ViewBuilder
    var errorView: some View {
        VStack(alignment: .trailing) {
            if let error = viewModel.displayError {
                VStack(alignment: .leading) {
                    Button("CLOSE_ERROR") {
                        viewModel.setError(nil)
                    }
                    Text(error.localizedDescription)
                        .font(.caption)
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.red)
                .cornerRadius(8)
                .transition(.move(edge: .trailing).combined(with: .blurReplace))
            }
            Spacer()
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

