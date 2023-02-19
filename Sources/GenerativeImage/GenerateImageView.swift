import SwiftUI

import Service

@available(iOS 16.2, *)
public struct GenerateImageView: View {

    @StateObject var manager = StableDiffusionService()
    @State var text = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Prompt", text: $text)

                Button("Generate") {
                    manager.generateImage(prompt: text)
                }
                .disabled(!manager.isReadyToGenerate)

                Section("Images") {
                    ProgressView(value: manager.progress)

                    ForEach(manager.images) { image in
                        Image(image.cgImage, scale: 1, label: Text(""))
                            .resizable()
                            .scaledToFit()
                    }
                }
                .font(.title2)

                Spacer()
            }
            .navigationTitle("Generate Image")
        }
    }
}
