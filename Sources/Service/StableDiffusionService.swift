import CoreGraphics
import Foundation

import StableDiffusion


public struct GenerationResult: Identifiable {
    public var id: Int { index }
    public var index: Int
    public var cgImage: CGImage
}

@available(iOS 16.2, *)
@MainActor
public class StableDiffusionService: ObservableObject {

    @Published public var progress: Double = 0
    @Published public var images: [GenerationResult] = []

    // When setup is complete and generation is not in progress, this will be true.
    @Published public var isReadyToGenerate = false

    var pipeline: StableDiffusionPipeline!

    public init() {
        setup()
    }

    private func setup() {
        let resourceURL = Bundle.module.url(forResource: "StableDiffusion", withExtension: nil)!

        do {
            let pipeline = try StableDiffusionPipeline(resourcesAt: resourceURL, reduceMemory: true)
            try pipeline.loadResources()
            self.pipeline = pipeline
            isReadyToGenerate = true
        } catch {
            print(error.localizedDescription)
        }
    }

    public func generateImage(
        prompt: String,
        imageCount: Int = 1,
        stepCount: Int = 50,
        seed: Int = 0,
        disableSafety: Bool = false
    ) {
        isReadyToGenerate = false
        progress = 0

        Task.detached {
            let images = try await self.pipeline.generateImages(
                prompt: prompt,
                imageCount: imageCount,
                stepCount: stepCount,
                seed: UInt32(seed),
                disableSafety: disableSafety
            ) { progress in

                DispatchQueue.main.async {
                    self.setProgress(progress: progress)
                }

                return true
            }

            await self.setImages(currentImages: images)
        }
    }

    func setProgress(progress: StableDiffusionPipeline.Progress) {
        self.progress = progress.step > 0
        ? Double(progress.step) / Double(progress.stepCount)
        : 0

        images = progress.currentImages.enumerated().compactMap { (n, image) in
            if let image {
                return GenerationResult(index: n, cgImage: image)
            } else {
                return nil
            }
        }
    }

    func setImages(currentImages: [CGImage?]) {
        progress = 1
        isReadyToGenerate = true
        images = currentImages.enumerated().compactMap { (n, image) in
            if let image {
                return GenerationResult(index: n, cgImage: image)
            } else {
                return nil
            }
        }
    }
}
