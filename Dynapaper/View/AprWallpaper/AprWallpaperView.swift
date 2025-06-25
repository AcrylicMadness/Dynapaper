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
    
    var body: some View {
        VStack {
            if let error = viewModel.displayError {
                Text(error.localizedDescription)
            }
            HStack {
                Spacer()
                ImageField(
                    image: $viewModel.lightImage,
                    onLoadError: { error in
                        viewModel.setError(error)
                    }
                )
                .frame(width: 200, height: 120)
                Spacer()
            }
        }
    }
}

#Preview {
    AprWallpaperView()
}
