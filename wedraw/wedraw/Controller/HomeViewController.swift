//
//  HomeViewController.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

struct DrawData {
    let unfinishedDraws: [DrawWithAngle]
    let finishedDraws: [DrawWithAngle]
}

class HomeViewController: UIViewController, SegmentedCardViewDelegate {
    var router: MainFlowRouter?
    let drawService = DrawService()
    var unfineshedDraws: [DrawWithAngle] = []
    var fineshedDraws: [DrawWithAngle] = []
    var allDraws: [Draw] = []
    
    private var homeView: HomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize view and load data first
        loadDraw()
        initializeHomeView()
        // Setup content after view is initialized
        setupContent()
        homeView.learnMoreButton.addTarget(self, action: #selector(infoButtonTapped), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar when view appears
        router?.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        // Always reload data when the view appears
        loadDraw()
        
        // Update UI with fresh data if homeView exists
        if homeView != nil {
            let allDrawData = DrawData(unfinishedDraws: unfineshedDraws, finishedDraws: fineshedDraws)
            homeView.updateData(with: allDrawData)
        }
        
        // Debug print to verify data is being refreshed
        print("⚠️ HomeVC viewWillAppear - Loaded \(unfineshedDraws.count) unfinished, \(fineshedDraws.count) finished")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // When navigating away, allow the next screen to show its navigation bar if needed
        router?.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func initializeHomeView() {
        let allDrawData = DrawData(unfinishedDraws: unfineshedDraws, finishedDraws: fineshedDraws)
        homeView = HomeView(frame: .zero, with: allDrawData)
        homeView.segmentedCardDelegate = self
        self.view = homeView
    }
    
    private func updateHomeView() {
        let allDrawData = DrawData(unfinishedDraws: unfineshedDraws, finishedDraws: fineshedDraws)
        homeView.updateData(with: allDrawData)
    }
    
    func loadDraw() {
        allDraws = drawService.getDraws()
        print("=== Loaded \(allDraws.count) total Draws ===")
        
        unfineshedDraws = drawService.getUnfinishedDraws()
        print("=== Loaded \(unfineshedDraws.count) Unfinished Draws ===")
        
        fineshedDraws = drawService.getFinishedDraws()
        print("=== Loaded \(fineshedDraws.count) Unfinished Draws ===")
    }
    
    let test: UILabel = {
        let label = UILabel()
        label.text = "TEST"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupContent() {
        let models = [
            ("Male", "MaleHead", true),
            ("Female", "FemaleHead", false),
            ("Boy", "model-1", false),
            ("Girl", "model-2", false)
        ]
        
        for (title, image, availability) in models {
            let card = createCardView(with: title, with: image, with: availability)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(modelCardTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            card.isUserInteractionEnabled = true
            homeView.modelsStackView.addArrangedSubview(card)
        }
    }
    
    private func createCardView(with title: String, with image: String, with availability: Bool) -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 20

        card.layer.borderColor = UIColor(named: "Inkredible-LightPurple")?.cgColor
        card.layer.borderWidth = 1.5
        card.backgroundColor = .white
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: 273).isActive = true
        card.heightAnchor.constraint(equalToConstant: 160).isActive = true
    
        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .white

        label.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true

        
        let imageView = UIImageView()
        imageView.image = UIImage(named: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false


        
        card.addSubview(label)
        card.addSubview(imageView)
        
        if !availability {
           let overlay = UIView()
            overlay.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
           overlay.translatesAutoresizingMaskIntoConstraints = false
           overlay.layer.cornerRadius = 20
           overlay.clipsToBounds = true

           let comingSoonLabel = UILabel()
           comingSoonLabel.text = "Coming Soon"
           comingSoonLabel.textColor = .white
           comingSoonLabel.font = UIFont.preferredFont(forTextStyle: .headline)
           comingSoonLabel.textAlignment = .center
           comingSoonLabel.translatesAutoresizingMaskIntoConstraints = false

           overlay.addSubview(comingSoonLabel)
           card.addSubview(overlay)

           NSLayoutConstraint.activate([
               overlay.topAnchor.constraint(equalTo: card.topAnchor),
               overlay.leadingAnchor.constraint(equalTo: card.leadingAnchor),
               overlay.trailingAnchor.constraint(equalTo: card.trailingAnchor),
               overlay.bottomAnchor.constraint(equalTo: card.bottomAnchor),

               comingSoonLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
               comingSoonLabel.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
           ])
       }

        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: -36),
            imageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        return card
    }
    
    // LSAJDlkjd
    @objc func infoButtonTapped() {
        router?.presentDirectly(.loomishDetailViewController, animated: true)
    }
    
    @objc private func modelCardTapped(_ sender: UITapGestureRecognizer) {
        router?.navigate(to: .setAngleViewController, animated: true)
    }
    
    @objc func didTapDrawCard(draw: Draw) {
        print("draw data",draw)
        print("draw card tapped")
        
        // Check if the draw is finished
        if draw.is_finished {
            // Navigate to ListFinishedDrawingViewController for finished draws
//            let listFinishedVC = ListFinishedDrawingViewController()
//            listFinishedVC.router = self.router
//            listFinishedVC.drawData = draw // Pass the draw data
            
            if let router = router {
//                router.navigationController?.pushViewController(listFinishedVC, animated: true)
                router.navigate(
                    to: .listFinishedDrawingViewController(draw),
                    animated: true
                )
            } else {
                let listFinishedVC = ListFinishedDrawingViewController(drawData: draw)
                            listFinishedVC.router = self.router
                navigationController?.pushViewController(listFinishedVC, animated: true)
            }
        } else {
            // Handle unfinished draws with existing logic
//            var drawVC = UIViewController()
            if draw.draw_mode == "reference" {
//                drawVC = DrawingStepsViewController(drawID: draw.draw_id)
                self.router?.navigate(
                    to: .drawingStepsViewController(draw.draw_id),
                    animated: true
                )
            } else {
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
                                to: .arTracingViewController(image, tracingImage,drawId: draw.draw_id),
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
            }
//            navigationController?.setViewControllers([drawVC], animated: true)
        }
    }
}
