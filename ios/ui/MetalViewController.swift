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
        do {
            LogOverlay.shared().addEntry("Step 1 — viewDidLoad entered", isError: false)

            // Step 2: get CAMetalLayer from view
            guard let layer = view.layer as? CAMetalLayer else {
                LogOverlay.shared().addEntry("Step 2 FAILED: view.layer is not CAMetalLayer", isError: true)
                return
            }
            metalLayer = layer
            LogOverlay.shared().addEntry("Step 2 OK — CAMetalLayer from view.layer", isError: false)

            // Step 3: create Metal device
            guard let device = MTLCreateSystemDefaultDevice() else {
                LogOverlay.shared().addEntry("Step 3 FAILED: MTLCreateSystemDefaultDevice returned nil", isError: true)
                return
            }
            metalLayer.device = device
            LogOverlay.shared().addEntry("Step 3 OK — Metal device: \(device.name)", isError: false)

            // Step 4: configure layer properties
            metalLayer.pixelFormat = .bgra8Unorm
            metalLayer.framebufferOnly = true
            metalLayer.frame = view.bounds
            metalLayer.isOpaque = true
            LogOverlay.shared().addEntry("Step 4 OK — layer configured", isError: false)

            // Step 5: set Metal layer on bridge BEFORE startVM
            BionicSX2Bridge.setMetalLayer(metalLayer)
            LogOverlay.shared().addEntry("Step 5 OK — setMetalLayer on bridge", isError: false)

            // Step 6: find ISO
            let isoPath = findFirstISO()
            if isoPath != nil {
                LogOverlay.shared().addEntry("Step 6 — ISO found: \(isoPath!)", isError: false)
            } else {
                LogOverlay.shared().addEntry("Step 6 — no ISO found, running without disc", isError: false)
            }

            // Step 7: start VM
            LogOverlay.shared().addEntry("Step 7 — calling startVM...", isError: false)
            if BionicSX2Bridge.startVM(isoPath: isoPath) {
                LogOverlay.shared().addEntry("Step 7 OK — VM started, surface created", isError: false)

                // Step 8: start render loop
                LogOverlay.shared().addEntry("Step 8 — starting displayLink render loop", isError: false)
                displayLink = CADisplayLink(target: self, selector: #selector(renderFrame))
                displayLink.add(to: .main, forMode: .common)
                LogOverlay.shared().addEntry("viewDidLoad complete — render loop running", isError: false)
            } else {
                LogOverlay.shared().addEntry("Step 7 FAILED: startVM returned false — Surface FAILED", isError: true)
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let ml = metalLayer {
            ml.frame = view.bounds
            ml.drawableSize = CGSize(
                width: view.bounds.width * view.contentScaleFactor,
                height: view.bounds.height * view.contentScaleFactor
            )
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.invalidate()
    }

    @objc func renderFrame() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
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
