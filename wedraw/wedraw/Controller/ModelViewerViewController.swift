import UIKit
import SceneKit

struct ModelConfig {
    let zoomDistance: Float
    let position: SCNVector3
    let rotation: SCNVector3 // Euler angles in radians
}

class ModelViewerViewController: UIViewController {
    private let rotationLabel = UILabel()
    private let sceneView = SCNView()
    private let backButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    private let modelNames = ["head", "step1", "step2", "step3", "step4", "step5", "step6", "step7", "step8", "step9", "step10fix2"]
    private var currentModelIndex = 8
    private var currentModelNode: SCNNode?
    private var displayLink: CADisplayLink?

    private let modelConfigs: [String: ModelConfig] = [
        "head": ModelConfig(
            zoomDistance: 2.0,
            position: SCNVector3(0, 0, 0),
            rotation: SCNVector3(-Float.pi/1.6, Float.pi/3, 0)
        ),
        "step1": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step2": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step3": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step4": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step5": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step6": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step7": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step8": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step9": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
        "step10fix2": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0.1, 0, 0),
            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
        ),
//        "step10": ModelConfig(
//            zoomDistance: 4.8,
//            position: SCNVector3(0.1, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
//        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSceneView()
        setupButtons()
        setupRotationLabel()
        setupDisplayLink()
        loadModel(named: modelNames[currentModelIndex])
    }

    private func setupSceneView() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        view.addSubview(sceneView)

        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }

    private func setupButtons() {
        backButton.setTitle("Back", for: .normal)
        nextButton.setTitle("Next", for: .normal)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [backButton, nextButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupRotationLabel() {
        rotationLabel.translatesAutoresizingMaskIntoConstraints = false
        rotationLabel.textAlignment = .center
        rotationLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        rotationLabel.textColor = .darkGray
        rotationLabel.numberOfLines = 2
        view.addSubview(rotationLabel)

        NSLayoutConstraint.activate([
            rotationLabel.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -10),
            rotationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotationLabel))
        displayLink?.add(to: .current, forMode: .default)
    }

    @objc private func updateRotationLabel() {
        guard let node = currentModelNode else { return }
        let rotation = node.eulerAngles
        let degrees = SCNVector3(
            rotation.x * 180 / .pi,
            rotation.y * 180 / .pi,
            rotation.z * 180 / .pi
        )
        rotationLabel.text = String(format: "Rotation:\nX: %.1f°  Y: %.1f°  Z: %.1f°",
                                    degrees.x, degrees.y, degrees.z)
    }

    private func loadModel(named name: String) {
        guard let scene = SCNScene(named: "SceneKit Asset Catalog.scnassets/\(name).scn") else {
            print("Model \(name) not found.")
            return
        }

        sceneView.scene = scene

        // Remove any old cameras
        scene.rootNode.childNodes.filter { $0.camera != nil }.forEach { $0.removeFromParentNode() }

        let config = modelConfigs[name] ?? ModelConfig(
            zoomDistance: 5.0,
            position: SCNVector3(0, 0, 0),
            rotation: SCNVector3(0, 0, 0)
        )

        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, config.zoomDistance)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode

        // Set model position/rotation
        if let modelNode = scene.rootNode.childNodes.first {
            modelNode.position = config.position
            modelNode.eulerAngles = config.rotation
            currentModelNode = modelNode
        }
    }

    @objc private func backTapped() {
        currentModelIndex = max(0, currentModelIndex - 1)
        loadModel(named: modelNames[currentModelIndex])
    }

    @objc private func nextTapped() {
        
        currentModelIndex = min(modelNames.count - 1, currentModelIndex + 1)
        loadModel(named: modelNames[currentModelIndex])
        
        exportSceneSnapshot()
    }
    private func exportSceneSnapshot2() {
        let image = sceneView.snapshot()

        guard let pngData = image.pngData() else {
            print("❌ Failed to convert snapshot to PNG")
            return
        }

        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("SceneSnapshot_\(Date().timeIntervalSince1970).png")

        do {
            try pngData.write(to: fileURL)
        } catch {
            print("❌ Failed to save PNG: \(error)")
            return
        }

        // Present share sheet
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        present(activityVC, animated: true, completion: nil)
    }
    private func exportSceneSnapshot() {
            guard let scene = sceneView.scene,
                  let pointOfView = sceneView.pointOfView,
                  let device = MTLCreateSystemDefaultDevice(),
                  let commandQueue = device.makeCommandQueue() else {
                print("❌ Metal unavailable or scene missing")
                return
            }
            if scene.rootNode.childNodes.allSatisfy({ $0.light == nil }) {
//                let lightNode = SCNNode()
//                let light = SCNLight()
//                light.type = .omni
//                light.intensity = 750
//                light.color = UIColor.white
//                lightNode.light = light
//                lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
//                scene.rootNode.addChildNode(lightNode)
                
                // Ambient light (fills scene uniformly, no direction)
                    let ambientLightNode = SCNNode()
                    let ambientLight = SCNLight()
                    ambientLight.type = .ambient
                    ambientLight.intensity = 500 // Try 500–1000 depending on your model
                    ambientLight.color = UIColor.white
                    ambientLightNode.light = ambientLight
                    scene.rootNode.addChildNode(ambientLightNode)

                    // Omni light (adds depth and highlights)
                    let omniLightNode = SCNNode()
                    let omniLight = SCNLight()
                    omniLight.type = .omni
                    omniLight.intensity = 500
                    omniLight.color = UIColor.white
                    omniLightNode.light = omniLight
                    omniLightNode.position = SCNVector3(x: 5, y: 5, z: 10)
                    scene.rootNode.addChildNode(omniLightNode)
            }

            let renderer = SCNRenderer(device: device, options: nil)
            renderer.scene = scene
            renderer.pointOfView = pointOfView

            let scale = UIScreen.main.scale
            let width = Int(sceneView.bounds.width * scale)
            let height = Int(sceneView.bounds.height * scale)

            let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .bgra8Unorm,
                width: width,
                height: height,
                mipmapped: false
            )
            textureDesc.usage = [.renderTarget, .shaderRead]
            textureDesc.storageMode = .shared

            guard let texture = device.makeTexture(descriptor: textureDesc) else {
                print("❌ Failed to create texture")
                return
            }

            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = texture
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store
            passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0) // Transparent

            guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                print("❌ Failed to create command buffer")
                return
            }

            renderer.render(
                atTime: CACurrentMediaTime(),
                viewport: CGRect(x: 0, y: 0, width: width, height: height),
                commandBuffer: commandBuffer,
                passDescriptor: passDescriptor
            )

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            let bytesPerRow = width * 4
            var rawData = [UInt8](repeating: 0, count: width * height * 4)
            texture.getBytes(
                &rawData,
                bytesPerRow: bytesPerRow,
                from: MTLRegionMake2D(0, 0, width, height),
                mipmapLevel: 0
            )

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let context = CGContext(
                data: &rawData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ),
            let cgImage = context.makeImage() else {
                print("❌ Failed to create image from buffer")
                return
            }

            let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
            guard let pngData = image.pngData() else {
                print("❌ Failed to get PNG data")
                return
            }

            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("SceneSnapshot_\(Date().timeIntervalSince1970).png")
            do {
                try pngData.write(to: fileURL)
            } catch {
                print("❌ Failed to write PNG: \(error)")
                return
            }

            // Present share sheet
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            present(activityVC, animated: true, completion: nil)
        }

    deinit {
        displayLink?.invalidate()
    }
}

#Preview {
    ModelViewerViewController()
}
