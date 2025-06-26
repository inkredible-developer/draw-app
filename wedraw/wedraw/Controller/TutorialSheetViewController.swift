//
//  TutorialSheetViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit
import AVFoundation
import TOCropViewController
import CropViewController

final class TutorialSheetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    private var cameraCoordinator: CameraCoordinator?
    
    var drawService = DrawService()
    var router : MainFlowRouter?
  // MARK: – UI
  private let container = UIView()
  private let titleLabel = UILabel()
  private let videoContainer = UIView()
  private let descriptionLabel = UILabel()
  private var tooltip: TooltipView?
    private lazy var actionButton = CustomButton(
        title: mode == .reference ? "Start Drawing" : "Take an Anchor",
        backgroundColor: UIColor(named: "Inkredible-Green") ?? .systemGreen,
        titleColor: UIColor(named: "Inkredible-DarkText") ?? .black
    )
    
    private let infoButton = CustomIconButtonView(iconName: "info", iconColor: .white, backgroundColor: UIColor(named: "Inkredible-DarkText") ?? .systemYellow, iconScale: 0.5)
    private let closeButton = CustomIconButtonView(iconName: "xmark", iconColor: UIColor(named: "Inkredible-Red") ?? .systemRed, backgroundColor: UIColor(named: "Inkredible-DarkText") ?? .green, iconScale: 0.5)

  // MARK: – Video
  private var queuePlayer: AVQueuePlayer?
  private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    private var isVideoReadyToPlay = false
    private var playerItem: AVPlayerItem?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerReadyObserver: NSKeyValueObservation?

    private let mode: DrawingMode
    private let selectedAngle: Angle
    
    // MARK: - Image Properties
    private var anchorImage: UIImage?

  init(mode: DrawingMode, angle: Angle) {
    self.mode = mode
    self.selectedAngle = angle
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .pageSheet
    if let sheet = sheetPresentationController, #available(iOS 16.0, *) {
      let customDetent = UISheetPresentationController.Detent.custom { ctx in
        ctx.maximumDetentValue * 0.85
      }
      sheet.detents = [customDetent]
      sheet.prefersGrabberVisible = true
    }
  }
  required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        setupUI()
        preloadVideoAssets()
    }
    
    private func preloadVideoAssets() {
        guard let url = Bundle.main.url(
            forResource: mode == .reference ? "reference_tutorial" : "live_tutorial",
            withExtension: "MP4"
        ) else { return }
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: videoContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: videoContainer.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
        
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem!)
        
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resizeAspectFill
        videoContainer.layer.addSublayer(playerLayer!)
        playerLayer?.frame = videoContainer.bounds
        
        queuePlayer?.automaticallyWaitsToMinimizeStalling = false
        
        playerItemStatusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard let self = self, item.status == .readyToPlay else { return }
            
            DispatchQueue.main.async {
                self.isVideoReadyToPlay = true
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
                
                if self.viewIfLoaded?.window != nil {
                    self.queuePlayer?.play()
                }
            }
        }
        
        queuePlayer?.play()
        queuePlayer?.pause()
    }

    private func setupVideoLoop() {
        if let playerLayer = playerLayer {
            videoContainer.layer.addSublayer(playerLayer)
            playerLayer.frame = videoContainer.bounds
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        playerLayer?.frame = videoContainer.bounds
        if isVideoReadyToPlay {
            queuePlayer?.play()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !(queuePlayer?.rate.isEqual(to: 1.0) ?? false) {
            queuePlayer?.play()
        }
    }

    deinit {
        playerItemStatusObserver?.invalidate()
        playerReadyObserver?.invalidate()
        queuePlayer?.pause()
        playerLayer?.removeFromSuperlayer()
    }

  private func setupUI() {
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
    container.layer.cornerRadius = 20
    view.addSubview(container)
      
      infoButton.delegate = self
      closeButton.delegate = self

      infoButton.updateSize(width: 30)
      closeButton.updateSize(width: 30)
      
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)
      titleLabel.textColor = .white
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.text = mode == .reference
      ? "You need to adjust the selected angle into your desired image position"
      : "You need to register an anchor for this drawing session."

    videoContainer.translatesAutoresizingMaskIntoConstraints = false
    videoContainer.backgroundColor = UIColor(named: "Inkredible-DarkText")
    videoContainer.layer.cornerRadius = 12
    videoContainer.clipsToBounds = true

    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)
      descriptionLabel.textColor = .white
    descriptionLabel.textAlignment = .center
    descriptionLabel.numberOfLines = 0
    descriptionLabel.text = mode == .reference
      ? "Look for something comfortable so you can draw with more focus"
      : "Look for something with rich texture or detail like a card, snack, or a patterned item. Avoid reflective surface."

      actionButton.delegate = self

    [infoButton, closeButton, titleLabel, videoContainer, descriptionLabel, actionButton]
      .forEach { container.addSubview($0) }

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

      infoButton.topAnchor.constraint(equalTo: container.topAnchor),
      infoButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),

      closeButton.topAnchor.constraint(equalTo: container.topAnchor),
      closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),

      titleLabel.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 12),
      titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20),

      videoContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      videoContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      videoContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      videoContainer.heightAnchor.constraint(equalTo: videoContainer.widthAnchor),

      descriptionLabel.topAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: 12),
      descriptionLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
      descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20),

      actionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      actionButton.heightAnchor.constraint(equalToConstant: 55),
      actionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])
  }
    
    @objc private func toggleTooltip() {
      tooltip?.removeFromSuperview()
      
      let text = mode == .reference
        ? "This shows how to align your reference under camera."
        : "Anchor is needed to display step-by-step images of the selected angle."
      
      let tip = TooltipView(text: text) { [weak self] in
        self?.tooltip = nil
      }
      
      tip.translatesAutoresizingMaskIntoConstraints = false
      container.addSubview(tip)
      tooltip = tip
      
      NSLayoutConstraint.activate([
        tip.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 8),
        tip.leadingAnchor.constraint(equalTo: infoButton.leadingAnchor),
        tip.widthAnchor.constraint(equalToConstant: 250),
        tip.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
      ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainer.bounds
    }

  @objc private func dismissSheet() {
    dismiss(animated: true)
  }
    
    private func captureAnchorPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            if let image = info[.originalImage] as? UIImage {
                let fixedImage = image.normalizedImage()
                self.anchorImage = fixedImage
                
                // Move to cropping step automatically
                cropAnchorPhoto()
            }
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func cropAnchorPhoto() {
        guard let image = anchorImage else { return }
        let cropVC = CropViewController(image: image)
        cropVC.delegate = self
        present(cropVC, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.anchorImage = image
        cropViewController.dismiss(animated: true) {
            self.startARTracing()
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) { [weak self] in
            if cancelled {
                // Dismiss the entire TutorialSheetViewController to return to SelectDrawingModeVC
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func startARTracing() {
//            guard let anchorImage = anchorImage else { return }
//            let arVC = ARTracingViewController()
//            arVC.anchorImage = anchorImage
//            arVC.tracingImage = tracingImage
//            arVC.modalPresentationStyle = .fullScreen
//            present(arVC, animated: true)
    }
    
}


extension TutorialSheetViewController: CustomIconButtonViewDelegate {
    func didTapCustomViewButton(_ button: CustomIconButtonView) {
        if button === infoButton {
            toggleTooltip()
        } else if button === closeButton {
            dismissSheet()
        }
    }
}

extension TutorialSheetViewController: CustomButtonDelegate {
    func customButtonDidTap(_ button: CustomButton) {
        if button === actionButton {
            let draw_id = UUID()
            self.drawService.createDraw(
                draw_id: draw_id,
                angle_id: selectedAngle.angle_id!,
                draw_mode: mode.type
            )
            if mode == .liveAR {
                // Create the coordinator BEFORE dismissing the sheet
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    
                    // Store coordinator in SceneDelegate to keep it alive
                    sceneDelegate.cameraCoordinator = CameraCoordinator(
                        presentingViewController: rootVC,
                        router: self.router,
                        onImageCropped: { [weak sceneDelegate] image in
                            guard let tracingImage = UIImage(named: "traceng") else { return }
                            
                            // Navigate to AR tracing screen with the cropped image
                            self.router?.navigate(
                                to: .arTracingViewController(image, tracingImage, drawId: draw_id),
                                animated: true
                            )
                            
                            // Clear reference when done
                            sceneDelegate?.cameraCoordinator = nil
                        }
                    )
                    
                    // Then dismiss
                    dismiss(animated: true) {
                        // Start camera after dismiss animation completes
                        sceneDelegate.cameraCoordinator?.startCamera()
                    }
                }
            } else {
                    let drawVC = DrawingStepsViewController(drawID: draw_id)
                    navigationController?.setViewControllers([drawVC], animated: true)
                    dismiss(animated: true) {
                        print("get here")
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                             let window = windowScene.windows.first else {
                           return
                        }
                        
                        let navController = UINavigationController(rootViewController: drawVC)
                        navController.interactivePopGestureRecognizer?.isEnabled = false

                            window.rootViewController = navController
                            window.makeKeyAndVisible()
                    }
            }
        }
    }
}
extension UIViewController {
    var topmostPresentedViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topmostPresentedViewController
        }
        return self
    }
}

extension UIImage {
    func normalizedImage() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}

// Add this to your project
class CameraCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    private weak var presentingViewController: UIViewController?
    private var onImageCropped: ((UIImage) -> Void)?
    private var router: MainFlowRouter?
    
    init(presentingViewController: UIViewController, router: MainFlowRouter?, onImageCropped: @escaping (UIImage) -> Void) {
        self.presentingViewController = presentingViewController
        self.router = router
        self.onImageCropped = onImageCropped
        super.init()
    }
    
    
    func startCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        presentingViewController?.present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            let fixedImage = image.normalizedImage()
            presentCropViewController(with: fixedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Crop functionality
    private func presentCropViewController(with image: UIImage) {
        let cropVC = CropViewController(image: image)
        cropVC.delegate = self
        presentingViewController?.present(cropVC, animated: true)
    }
    
    // MARK: - CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.onImageCropped?(image)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
}
