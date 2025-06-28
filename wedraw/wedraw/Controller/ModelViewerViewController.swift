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
    private var originalModelScale: SCNVector3?
    private let galleryButton = UIButton(type: .system)
    private let exportAllButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let modelNames = ["head", "step1", "step2", "step3", "step4", "step5", "step6", "step7", "step8", "step9", "step10fix"]
    private var currentModelIndex = 0
    private var currentModelNode: SCNNode?
    private var displayLink: CADisplayLink?

    private let modelConfigs: [String: ModelConfig] = [
        "head": ModelConfig(
            zoomDistance: 2.0,
            position: SCNVector3(0, 0, 0),
            rotation: SCNVector3(-Float.pi/1.5, Float.pi/3, 0)
        ),
        "step1": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step2": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step3": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step4": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step5": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
//        "kerangkaa": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0.1, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
//        ),
        "step6": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step7": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step8": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step9": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step10fix": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
//        "step10": ModelConfig(
//            zoomDistance: 4.8,
//            position: SCNVector3(0.1, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
//        )
    ]
    
    
//    private let modelConfigs: [String: ModelConfig] = [
//        "head": ModelConfig(
//            zoomDistance: 2.0,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/1.5,0, 0)
//        ),
//        "step1": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step2": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step3": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step4": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step5": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
////        "kerangkaa": ModelConfig(
////            zoomDistance: 2.7,
////            position: SCNVector3(0.1, 0, 0),
////            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
////        ),
//        "step6": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step7": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step8": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step9": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        ),
//        "step10fix": ModelConfig(
//            zoomDistance: 2.7,
//            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2,0, 0)
//        )
//    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSceneView()
        setupButtons()
        setupRotationLabel()
        setupDisplayLink()
        loadModel(named: modelNames[currentModelIndex])
        setupGalleryButton()
    }
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupGalleryButton() {
        galleryButton.setTitle("Gallery", for: .normal)
        galleryButton.setTitleColor(.systemBlue, for: .normal)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        view.addSubview(galleryButton)

        NSLayoutConstraint.activate([
            galleryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            galleryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func openGallery() {
        let galleryVC = GalleryViewController()
        navigationController?.pushViewController(galleryVC, animated: true)
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
//        backButton.setTitle("Back", for: .normal)
//        nextButton.setTitle("Next", for: .normal)
//
//        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
//
//        let buttonStack = UIStackView(arrangedSubviews: [backButton, nextButton])
//        buttonStack.axis = .horizontal
//        buttonStack.spacing = 20
//        buttonStack.distribution = .fillEqually
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(buttonStack)
//
//        NSLayoutConstraint.activate([
//            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            buttonStack.heightAnchor.constraint(equalToConstant: 44),
//            buttonStack.widthAnchor.constraint(equalToConstant: 200)
//        ])
        exportAllButton.setTitle("Export All", for: .normal)
        exportAllButton.addTarget(self, action: #selector(exportAllTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [backButton, nextButton, exportAllButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

//    @objc private func exportAllTapped() {
//        exportAllModels(at: 0)
//    }
//
//    private func exportAllModels(at index: Int) {
//        guard index < modelNames.count else {
//            print("✅ All models exported")
//            return
//        }
//
//        let modelName = modelNames[index]
//        print("📦 Exporting model: \(modelName)")
//        loadModel(named: modelName)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.exportSceneSnapshot()
//            self.exportAllModels(at: index + 1)
//        }
//    }
    @objc private func exportAllTapped() {
        Task.detached { [weak self] in
            await self?.exportAllModelsInBackground()
        }
        
        
        activityIndicator.startAnimating()
        exportAllButton.isEnabled = false

        Task {
            for name in modelNames {
                await exportModelNamed(name)
            }

            await MainActor.run {
                self.activityIndicator.stopAnimating()
                self.exportAllButton.isEnabled = true

                let alert = UIAlertController(title: "Done", message: "All models exported.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    private func exportAllModelsInBackground() async {
        for modelName in modelNames {
            print("📦 Exporting: \(modelName)")
            await exportModelNamed(modelName)
        }
        print("✅ Finished exporting all models")
    }

    private func exportModelNamed(_ name: String) async {
        guard let scene = SCNScene(named: "SceneKit Asset Catalog.scnassets/\(name).scn") else {
            print("❌ Failed to load scene: \(name)")
            return
        }

        let config = modelConfigs[name] ?? ModelConfig(
            zoomDistance: 5.0,
            position: SCNVector3Zero,
            rotation: SCNVector3Zero
        )

        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, config.zoomDistance - 1.0)
        scene.rootNode.addChildNode(cameraNode)

        // Load and configure model
        if let modelNode = scene.rootNode.childNodes.first {
            modelNode.position = config.position
            modelNode.eulerAngles = config.rotation
            modelNode.scale = SCNVector3(1, 1, 1)
            modelNode.enumerateChildNodes { child, _ in
                child.geometry?.materials.forEach { $0.lightingModel = .constant }
            }
        }

        // Add ambient and omni light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500
        ambientLight.color = UIColor.white
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.intensity = 500
        omniLight.color = UIColor.white
        let omniNode = SCNNode()
        omniNode.light = omniLight
        omniNode.position = SCNVector3(5, 5, 10)
        scene.rootNode.addChildNode(omniNode)

        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            print("❌ Metal not available")
            return
        }

        let renderer = SCNRenderer(device: device, options: nil)
        renderer.scene = scene
        renderer.pointOfView = cameraNode

        let width = 1024
        let height = 1024
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm_srgb,
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
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)

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

        // Read pixels
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        texture.getBytes(&rawData, bytesPerRow: width * 4,
                         from: MTLRegionMake2D(0, 0, width, height),
                         mipmapLevel: 0)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            print("❌ Failed to create image")
            return
        }

        let image = UIImage(cgImage: cgImage)
        guard let pngData = image.pngData() else {
            print("❌ Failed to get PNG data")
            return
        }

        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Export_\(name).png")

        do {
            try pngData.write(to: fileURL)
            print("✅ Exported: \(fileURL.lastPathComponent)")
        } catch {
            print("❌ Save failed: \(error)")
        }
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
        
        
        // Setup camera
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.camera?.usesOrthographicProjection = true // Flat projection (optional)
//        cameraNode.camera?.orthographicScale = 1.5 // Adjust based on model size
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
//        scene.rootNode.addChildNode(cameraNode)
//        sceneView.pointOfView = cameraNode

        // Center and scale model
        if let modelNode = scene.rootNode.childNodes.first {
            modelNode.position = SCNVector3Zero
            modelNode.eulerAngles = config.rotation
            currentModelNode = modelNode
            
            originalModelScale = modelNode.scale

            // Auto-fit model in view (zoom effect)
//            let (minVec, maxVec) = modelNode.boundingBox
//            let size = SCNVector3(
//                x: maxVec.x - minVec.x,
//                y: maxVec.y - minVec.y,
//                z: maxVec.z - minVec.z
//            )
//            let maxDimension = max(size.x, max(size.y, size.z))
            let zoomScale = 1
            modelNode.scale = SCNVector3(zoomScale, zoomScale, zoomScale)


            modelNode.enumerateChildNodes { child, _ in
                child.geometry?.materials.forEach { material in
                    material.lightingModel = .constant
                }
            }
        }


        // Set model position/rotation
        if let modelNode = scene.rootNode.childNodes.first {
            modelNode.position = config.position
            modelNode.eulerAngles = config.rotation
            currentModelNode = modelNode
            modelNode.enumerateChildNodes { child, _ in
                child.geometry?.materials.forEach { material in
                    material.lightingModel = .constant // disables lighting influence
                }
            }
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
            scene.rootNode.enumerateChildNodes { (node, _) in
                node.light?.castsShadow = false
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
//            renderer.pointOfView = pointOfView

            let exportCamera = SCNNode()
            exportCamera.camera = SCNCamera()
            exportCamera.position = SCNVector3(0, 0, (pointOfView.position.z - 1.0)) // move closer by 1.0
            renderer.pointOfView = exportCamera
//            let scale = UIScreen.main.scale
//            let width = Int(sceneView.bounds.width * scale)
//            let height = Int(sceneView.bounds.height * scale)

            let viewSize = sceneView.bounds.size
            let scale = UIScreen.main.scale
            let minLength = min(viewSize.width, viewSize.height)
            let dimension = Int(minLength * scale)
//        
//            let width = dimension
//            let height = dimension
        
            let width = 1024
            let height = 1024
        
            let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .bgra8Unorm_srgb,
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
//            if let modelNode = currentModelNode {
//                let zoomScale = 1.5
//                modelNode.scale = SCNVector3(zoomScale, zoomScale, zoomScale)
//            }
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
//
//            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("SceneSnapshot_\(Date().timeIntervalSince1970).png")
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("SceneSnapshot_\(Date().timeIntervalSince1970).png")

            do {
                try pngData.write(to: fileURL)
            } catch {
                print("❌ Failed to write PNG: \(error)")
                return
            }

//            // Present share sheet
//            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//            activityVC.popoverPresentationController?.sourceView = self.view
//            present(activityVC, animated: true, completion: nil)
        
//            if let modelNode = currentModelNode, let originalScale = originalModelScale {
//                modelNode.scale = originalScale
//            }
            scene.rootNode.childNodes
                .filter { $0.light != nil }
                .forEach { $0.removeFromParentNode()}
    }

    deinit {
        displayLink?.invalidate()
    }
}

#Preview {
    ModelViewerViewController()
}
