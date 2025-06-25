//
//  HomeViewController.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit


struct DrawData {
    let unfineshedDraws: [Draw]
    let fineshedDraws: [Draw]
}
class HomeViewController: UIViewController, SegmentedCardViewDelegate {
    var router: MainFlowRouter?
    let drawService = DrawService()
    var unfineshedDraws: [Draw] = []
    var fineshedDraws: [Draw] = []
    var allDraws: [Draw] = []
    
    
    private var homeView: HomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDraw()
        
        let allDrawData = DrawData(unfineshedDraws: unfineshedDraws, fineshedDraws: fineshedDraws)
        homeView = HomeView(frame: .zero, with: allDrawData)
        homeView.segmentedCardDelegate = self
        self.view = homeView
        
        setupContent()
        homeView.learnMoreButton.addTarget(self, action: #selector(infoButtonTapped),for: UIControl.Event.touchUpInside)
    }
    
    func loadDraw() {
        allDraws = drawService.getDraws()
        print("=== Loaded \(allDraws.count) total Draws ===")
        for draw in allDraws {
            let drawId = draw.draw_id
            let angleId = draw.angle_id
            let currentStep = draw.current_step
            let similarityScore = draw.similarity_score
            let finishedImage = draw.finished_image ?? "No Image"
            let isFinished = draw.is_finished

            print("""
            🔹 Draw ID: \(drawId)
               - Angle ID: \(angleId)
               - Current Step: \(currentStep)
               - Similarity Score: \(similarityScore)
               - Is Finished: \(isFinished)
               - Finished Image: \(finishedImage)
            """)
        }
        
        unfineshedDraws = drawService.getUnfinishedDraws()
        print("=== Loaded \(unfineshedDraws.count) Unfinished Draws ===")
        for draw in unfineshedDraws {
            let drawId = draw.draw_id
            let angleId = draw.angle_id
            let currentStep = draw.current_step
            let similarityScore = draw.similarity_score
            let finishedImage = draw.finished_image ?? "No Image"
            let isFinished = draw.is_finished

            print("""
            🔹 Draw ID: \(drawId)
               - Angle ID: \(angleId)
               - Current Step: \(currentStep)
               - Similarity Score: \(similarityScore)
               - Is Finished: \(isFinished)
               - Finished Image: \(finishedImage)
            """)
        }
        
        
        fineshedDraws = drawService.getFinishedDraws()
        print("=== Loaded \(fineshedDraws.count) FinishedDraws ===")
        for draw in fineshedDraws {
            let drawId = draw.draw_id
            let angleId = draw.angle_id
            let currentStep = draw.current_step
            let similarityScore = draw.similarity_score
            let finishedImage = draw.finished_image ?? "No Image"
            let isFinished = draw.is_finished

            print("""
            🔹 Draw ID: \(drawId)
               - Angle ID: \(angleId)
               - Current Step: \(currentStep)
               - Similarity Score: \(similarityScore)
               - Is Finished: \(isFinished)
               - Finished Image: \(finishedImage)
            """)
        }
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

//        card.layer.borderColor = UIColor(red: 0.77, green: 0.72, blue: 0.99, alpha: 1).cgColor // light purple
        card.layer.borderColor = UIColor(named: "Inkredible-LightPurple")?.cgColor
        card.layer.borderWidth = 1.5
        card.backgroundColor = .white
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: 273).isActive = true
        card.heightAnchor.constraint(equalToConstant: 160).isActive = true
    
        let label = UILabel()
        label.text = title
//        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .white

//        label.backgroundColor = UIColor(red: 0.56, green: 0.52, blue: 0.88, alpha: 1) // deep purple
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
           overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
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
    
    
    @objc func infoButtonTapped() {
        print("tap")
        let infoVC = LoomishDetailViewController()
        infoVC.modalPresentationStyle = .formSheet
        if let sheet = infoVC.sheetPresentationController {

//            sheet.detents = [.large()]
            sheet.detents = [.medium()]
        }
        present(infoVC, animated: true, completion: nil)
    }
    
    @objc private func modelCardTapped(_ sender: UITapGestureRecognizer) {
        router?.navigate(to: .setAngleViewController, animated: true)
    }
    
    @objc func didTapDrawCard(draw: Draw) {
        print("draw data",draw)
        print("draw card tapped")
        var drawVC = UIViewController()
        if draw.draw_mode == "reference" {
            drawVC = DrawingStepsViewController()
        }else{
            drawVC = DrawingStepsUsingCameraController()
        }
        navigationController?.pushViewController(drawVC, animated: true)
    }
    
}
