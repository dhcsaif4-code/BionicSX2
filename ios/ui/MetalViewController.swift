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

        guard let device = MTLCreateSystemDefaultDevice() else {
            LogOverlay.shared().addEntry("Metal device: FAILED — MTLCreateSystemDefaultDevice returned nil", isError: true)
            return
        }
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.bounds
        metalLayer.isOpaque = true

        LogOverlay.shared().addEntry("Metal device: \(device.name)", isError: false)

        // CRITICAL: Set Metal layer BEFORE starting VM so the renderer
        // finds its CAMetalLayer during Create(GSVSyncMode, bool).
        BionicSX2Bridge.setMetalLayer(metalLayer)
        LogOverlay.shared().addEntry("Metal layer set on bridge", isError: false)

        // Start VM via C++ bridge
        let isoPath = findFirstISO()
        LogOverlay.shared().addEntry("Renderer init started", isError: false)
        if BionicSX2Bridge.startVM(isoPath: isoPath) {
            LogOverlay.shared().addEntry("Surface created", isError: false)
            LogOverlay.shared().addEntry("VM started — starting render loop", isError: false)
            // Start render loop only if VM started successfully
            displayLink = CADisplayLink(target: self, selector: #selector(renderFrame))
            displayLink.add(to: .main, forMode: .common)
        } else {
            LogOverlay.shared().addEntry("Surface FAILED: startVM returned false", isError: true)
            // Show alert so user knows what went wrong
            let alert = UIAlertController(
                title: "VM Start Failed",
                message: "The emulator could not start.\n\n"
                    + "Place a PS2 BIOS file (e.g. SCPH-39001.bin) in:\n"
                    + "Files App → BionicSX2 → BIOS/\n\n"
                    + "Check runtime.log in Documents/ for details.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
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
