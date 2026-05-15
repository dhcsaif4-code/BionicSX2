// AUDIT REFERENCE: Section 4.3
// STATUS: NEW
import UIKit
import Metal
import QuartzCore

class MetalViewController: UIViewController {
    var metalLayer: CAMetalLayer!

    override class var layerClass: AnyClass { CAMetalLayer.self }

    override func viewDidLoad() {
        super.viewDidLoad()
        metalLayer = view.layer as? CAMetalLayer
        metalLayer.device = MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.bounds

        // Start VM via C++ bridge
        let isoPath = findFirstISO()
        if !BionicSX2Bridge.startVM(isoPath: isoPath) {
            NSLog("[BionicSX2] iOSVMManager::StartVM failed")
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
