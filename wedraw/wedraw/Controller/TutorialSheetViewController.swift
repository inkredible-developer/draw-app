//
//  TutorialSheetViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//
// TutorialSheetViewController.swift
//
// TutorialSheetViewController.swift
// Revised with custom tooltip and adjusted layout
//

import UIKit
import AVFoundation

final class TutorialSheetViewController: UIViewController {
  // MARK: – UI
  private let container = UIView()
  private let infoButton = UIButton()
  private let closeButton = UIButton()
  private let titleLabel = UILabel()
  private let videoContainer = UIView()
  private let descriptionLabel = UILabel()
  private let actionButton = UIButton()
  private var tooltip: TooltipView?

  // MARK: – Video
  private var queuePlayer: AVQueuePlayer?
  private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    private var isVideoReadyToPlay = false
    private var playerItem: AVPlayerItem?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerReadyObserver: NSKeyValueObservation?

  private let mode: DrawingMode

  init(mode: DrawingMode) {
    self.mode = mode
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .pageSheet
    if let sheet = sheetPresentationController, #available(iOS 16.0, *) {
      let customDetent = UISheetPresentationController.Detent.custom { ctx in
        ctx.maximumDetentValue * 0.8
      }
      sheet.detents = [customDetent]
      sheet.prefersGrabberVisible = true
    }
  }
  required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        setupUI()
        // Preload video assets immediately
        preloadVideoAssets()
    }
    
    private func preloadVideoAssets() {
        guard let url = Bundle.main.url(
            forResource: mode == .reference ? "reference_tutorial" : "live_tutorial",
            withExtension: "MP4"
        ) else { return }
        
        // Create loading indicator in video container
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: videoContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: videoContainer.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
        
        // Use modern API instead of deprecated loadValuesAsynchronously
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem!)
        
        // Create player layer immediately
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resizeAspectFill
        videoContainer.layer.addSublayer(playerLayer!)
        playerLayer?.frame = videoContainer.bounds
        
        // Configure for immediate playback and watch for ready state
        queuePlayer?.automaticallyWaitsToMinimizeStalling = false
        
        // Observe player item status
        playerItemStatusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard let self = self, item.status == .readyToPlay else { return }
            
            DispatchQueue.main.async {
                self.isVideoReadyToPlay = true
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
                
                // Start playing if view is visible
                if self.viewIfLoaded?.window != nil {
                    self.queuePlayer?.play()
                }
            }
        }
        
        // Prefetch the asset by starting playback immediately and pausing
        queuePlayer?.play()
        queuePlayer?.pause()
    }

    private func setupVideoLoop() {
        // Only add the player layer to the hierarchy
        if let playerLayer = playerLayer {
            videoContainer.layer.addSublayer(playerLayer)
            playerLayer.frame = videoContainer.bounds
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure we have the latest layout
        view.layoutIfNeeded()
        
        // Fix the player layer frame in viewWillAppear
        playerLayer?.frame = videoContainer.bounds
        
        // Play if video is ready
        if isVideoReadyToPlay {
            queuePlayer?.play()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If video wasn't ready in viewWillAppear, try playing now
        // Fix the warning by using nil coalescing
        if !(queuePlayer?.rate.isEqual(to: 1.0) ?? false) {
            queuePlayer?.play()
        }
    }

    deinit {
        // Clean up observers
        playerItemStatusObserver?.invalidate()
        playerReadyObserver?.invalidate()
        queuePlayer?.pause()
        playerLayer?.removeFromSuperlayer()
    }

  private func setupUI() {
    // container
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .white
    container.layer.cornerRadius = 16
    view.addSubview(container)

    // infoButton
    infoButton.translatesAutoresizingMaskIntoConstraints = false
    infoButton.setImage(UIImage(named: "info_icon"), for: .normal)
    infoButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
    infoButton.tintColor = .systemBlue
    infoButton.layer.cornerRadius = 20
    infoButton.addTarget(self, action: #selector(toggleTooltip), for: .touchUpInside)

    // closeButton
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.setImage(UIImage(named: "close_icon"), for: .normal)
    closeButton.backgroundColor = UIColor(red: 0.92, green: 0.85, blue: 0.70, alpha: 1)
    closeButton.tintColor = .systemRed
    closeButton.layer.cornerRadius = 20
    closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)

    // titleLabel
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.text = mode == .reference
      ? "You need to adjust the selected angle into your desired image position"
      : "You need to register an anchor for this drawing session."

    // videoContainer
    videoContainer.translatesAutoresizingMaskIntoConstraints = false
    videoContainer.backgroundColor = .white
    videoContainer.layer.cornerRadius = 12
    videoContainer.clipsToBounds = true

    // descriptionLabel
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.font = .systemFont(ofSize: 12)
    descriptionLabel.textAlignment = .center
    descriptionLabel.numberOfLines = 0
    descriptionLabel.text = mode == .reference
      ? "Look for something comfortable so you can draw with more focus"
      : "Look for something with rich texture or detail like a card, snack, or a patterned item. Avoid reflective surface."

    // actionButton
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    actionButton.setTitle(mode == .reference ? "Start Drawing" : "Take an Anchor", for: .normal)
    actionButton.backgroundColor = .darkGray
    actionButton.setTitleColor(.white, for: .normal)
    actionButton.layer.cornerRadius = 12
    actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    actionButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)

    [infoButton, closeButton, titleLabel, videoContainer, descriptionLabel, actionButton]
      .forEach { container.addSubview($0) }

    // layout
    NSLayoutConstraint.activate([
      // container
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

      // infoButton (top left)
      infoButton.topAnchor.constraint(equalTo: container.topAnchor),
      infoButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      infoButton.widthAnchor.constraint(equalToConstant: 40),
      infoButton.heightAnchor.constraint(equalToConstant: 40),

      // closeButton (top right)
      closeButton.topAnchor.constraint(equalTo: container.topAnchor),
      closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      closeButton.widthAnchor.constraint(equalToConstant: 40),
      closeButton.heightAnchor.constraint(equalToConstant: 40),

      // titleLabel below buttons
      titleLabel.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 12),
      titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20),

      // videoContainer
      videoContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      videoContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      videoContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      videoContainer.heightAnchor.constraint(equalTo: videoContainer.widthAnchor),

      // descriptionLabel
      descriptionLabel.topAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: 12),
      descriptionLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
      descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20),

      // actionButton
//      actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
      actionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      actionButton.heightAnchor.constraint(equalToConstant: 52),
      actionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])
  }

//    private func setupVideoLoop() {
//        guard let url = Bundle.main.url(
//          forResource: mode == .reference ? "reference_tutorial" : "live_tutorial",
//          withExtension: "MP4"
//        ) else { return }
//
//        let asset = AVURLAsset(url: url)
//        let item  = AVPlayerItem(asset: asset)
//        queuePlayer = AVQueuePlayer(playerItem: item)
//        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: item)
//
//        playerLayer = AVPlayerLayer(player: queuePlayer)
//        playerLayer?.videoGravity = .resizeAspectFill
//        videoContainer.layer.addSublayer(playerLayer!)
//        
//        // Don't start playing here - we'll do it in viewDidAppear
//    }

    @objc private func toggleTooltip() {
      // Remove existing tooltip
      tooltip?.removeFromSuperview()
      
      // Create tooltip with text based on mode and a dismiss handler
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
        tip.widthAnchor.constraint(equalToConstant: 200),
        tip.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
      ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update the player layer frame after the view has been laid out
        playerLayer?.frame = videoContainer.bounds
    }

  @objc private func dismissSheet() {
    dismiss(animated: true)
  }
}
