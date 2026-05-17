// AUDIT REFERENCE: Section 4.3
// STATUS: NEW
import UIKit
import Metal
import QuartzCore

class MetalViewController: UIViewController {
    var metalLayer: CAMetalLayer!
    var displayLink: CADisplayLink!

    override class var layerClass: AnyClass { CAMetalLayer.self }

    override func viewDidLoad() {
        super.viewDidLoad()
        metalLayer = view.layer as? CAMetalLayer
        metalLayer.device = MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.bounds
        metalLayer.isOpaque = true

        // Start VM via C++ bridge
        let isoPath = findFirstISO()
        if !BionicSX2Bridge.startVM(isoPath: isoPath) {
            NSLog("[BionicSX2] iOSVMManager::StartVM failed")
        }

        // Start render loop
        displayLink = CADisplayLink(target: self, selector: #selector(renderFrame))
        displayLink.add(to: .main, forMode: .common)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metalLayer.frame = view.bounds
        metalLayer.drawableSize = CGSize(
            width: view.bounds.width * view.contentScaleFactor,
            height: view.bounds.height * view.contentScaleFactor
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.invalidate()
    }

    @objc func renderFrame() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = drawable.texture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        guard let commandQueue = metalLayer.device?.makeCommandQueue(),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func findFirstISO() -> String? {
        let documentsDir = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first ?? ""
        let gamesDir = documentsDir + "/Games"
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: gamesDir) else { return nil }
        for file in files where file.hasSuffix(".iso") || file.hasSuffix(".chd") || file.hasSuffix(".cso") {
            return gamesDir + "/" + file
        }
        return nil
    }
}
