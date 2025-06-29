//
//  FinishedDrawingViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit

class FinishedDrawingViewController: UIViewController, FinishedDrawingViewDelegate {
    var router: MainFlowRouter?
    var drawID: UUID?
    var userPhoto: UIImage
    private var finishedDrawingView: FinishedDrawingView!
    private let drawService = DrawService()
    
    var similarityScore: Int?
    
    init(drawID: UUID,
         similarityScore: Int,
         userPhoto: UIImage
    ) {
        self.drawID = drawID
        self.similarityScore = similarityScore
        self.userPhoto = userPhoto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        finishedDrawingView = FinishedDrawingView(
            resultImage: userPhoto,
            similarityValue: similarityScore ?? 0
            
        )
        view = finishedDrawingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finishedDrawingView.delegate = self
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Result"
        let finishButton = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(finishButtonTapped))
        finishButton.tintColor = UIColor(named: "Inkredible-DarkPurple")
        router?.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = finishButton
        navigationItem.hidesBackButton = true

    }
    
    @objc private func finishButtonTapped() {
        // Save progress logic can be added here
        saveProgress()
        navigateToHome()
    }
    
    func finishedDrawingViewDidTapDone(_ view: FinishedDrawingView) {
        // This method is called if the view itself has a done button
        // For now, we're using the navigation bar button instead
        finishButtonTapped()
    }
    
    private func saveProgress() {
        // Save the drawing as finished using insertDraw logic
        guard let drawID = drawID else {
            print("❌ No drawID available for saving")
            return
        }
        
        // Get the current draw details
        let drawDetails = drawService.getDrawById(draw_id: drawID)
        guard let draw = drawDetails.first else {
            print("❌ No draw found with ID: \(drawID)")
            return
        }
        
        // Calculate similarity score (you can implement your own logic here)
//        let similarityScore = calculateSimilarityScore()
        
        // Generate finished image path or data
        let finishedImagePath = generateFinishedImagePath()
        
        // Use the repository to insert/update the finished draw
        let repository = DrawRepository()
        repository.insertDraw(
            draw_id: drawID,
            angle_id: draw.angle_id,
            current_step: Int(draw.current_step),
            similarity_score: similarityScore ?? 9999,
            finished_image: finishedImagePath,
            is_finished: true,
            draw_mode: draw.draw_mode
        )
        
//        print("✅ Drawing saved as finished with ID: \(drawID), similarity score: \(similarityScore )")
    }
    
    private func calculateSimilarityScore() -> Int {
        // TODO: Implement your similarity calculation logic here
        // For now, return a random score between 60-95
        return Int.random(in: 60...95)
    }
    
    private func generateFinishedImagePath() -> String? {
        // TODO: Implement logic to save the finished drawing image
        // For now, return a placeholder path
        return "finished_drawing_\(drawID?.uuidString ?? UUID().uuidString).jpg"
    }
    
    private func navigateToHome() {
        // Navigate to home using router if available, otherwise manually
        if let router = router {
            router.navigateToRoot(animated: true)
        } else {
            // Manual navigation to home
            let homeVC = HomeViewController()
            let nav = UINavigationController(rootViewController: homeVC)
            homeVC.router = MainFlowRouter(navigationController: nav)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }
}

//#Preview {
////    FinishedDrawingViewController()
//}
