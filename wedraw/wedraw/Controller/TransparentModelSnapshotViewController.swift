import UIKit
import SceneKit
import Metal

class TransparentModelSnapshotViewController: UIViewController {
    let sceneView = SCNView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScene()
        setupButton()
    }

    private func setupScene() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear
        view.addSubview(sceneView)

        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let scene = SCNScene()
        let sphere = SCNSphere(radius: 1)
        let node = SCNNode(geometry: sphere)
        scene.rootNode.addChildNode(node)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(camera)

        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .omni
        light.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(light)

        scene.background.contents = UIColor.clear
        sceneView.scene = scene
        sceneView.pointOfView = camera
    }

    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("Export Transparent PNG", for: .normal)
        button.addTarget(self, action: #selector(exportTransparentImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func exportTransparentImage() {
        guard let scene = sceneView.scene,
              let pointOfView = sceneView.pointOfView,
              let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue()
        else {
            print("❌ Metal setup failed")
            return
        }

        let renderer = SCNRenderer(device: device, options: nil)
        renderer.scene = scene
        renderer.pointOfView = pointOfView

        let scale = UIScreen.main.scale
        let width = Int(sceneView.bounds.width * scale)
        let height = Int(sceneView.bounds.height * scale)

        // Create texture with alpha
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.storageMode = .shared

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            print("❌ Could not create texture")
            return
        }

        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0) // transparent

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        else {
            print("❌ Failed to create command buffer or encoder")
            return
        }

        renderEncoder.endEncoding()

        renderer.render(atTime: 0, viewport: CGRect(x: 0, y: 0, width: width, height: height), commandBuffer: commandBuffer, passDescriptor: passDescriptor)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Extract image from texture
        let bytesPerPixel = 4
        let byteCount = width * height * bytesPerPixel
        let bytesPerRow = width * bytesPerPixel
        var rawData = [UInt8](repeating: 0, count: byteCount)

        texture.getBytes(&rawData, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cgImage = context.makeImage()
        else {
            print("❌ Failed to create CGImage from texture")
            return
        }

        let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        guard let pngData = image.pngData() else {
            print("❌ Could not generate PNG")
            return
        }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("transparent_model_\(Date().timeIntervalSince1970).png")
        try? pngData.write(to: fileURL)

        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        present(activityVC, animated: true)
    }
}
