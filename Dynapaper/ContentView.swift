//
//  ContentView.swift
//  Dynapaper
//
//  Created by Acrylic M on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    
    private let proccessor = AprWallpaperProccessor()
    
    var body: some View {
        VStack {
            Button("Select light") {
                if let url = openFile() {
                    _ = try? proccessor.loadWallpaper(fromUrl: url, forMode: .light)
                }
            }
            Button("Select dark") {
                if let url = openFile() {
                    _ = try? proccessor.loadWallpaper(fromUrl: url, forMode: .dark)
                }
            }
            Button("Make heif") {
                do {
                    let data = try proccessor.makeHeif()
                    let url = FileManager.default.homeDirectoryForCurrentUser.appending(path: "wallpaper.heic")
                    try data.write(
                        to: url
                    )
                    print("Saved to \(url)")
                } catch {
                    print(error)
                }
            }
        }
        .padding()
    }
    
    // TODO: Move this somewhere
    func openFile() -> URL? {
        func showOpenPanel() -> URL? {
            let openpanel = NSOpenPanel()
            openpanel.title                = "Select Image"
            openpanel.isExtensionHidden    = false
            openpanel.canChooseDirectories = false
            openpanel.canChooseFiles       = true
            openpanel.allowsMultipleSelection = false
            openpanel.allowedContentTypes  = [.image]
            
            let response = openpanel.runModal()
            return response == .OK ? openpanel.url : nil
        }
        return showOpenPanel()
    }
}

#Preview {
    ContentView()
}
