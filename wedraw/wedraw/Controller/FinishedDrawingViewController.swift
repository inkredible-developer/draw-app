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
//        print("open this load view")
//        let drawDetail = drawService.getDrawById(draw_id: drawID!)
//        if drawDetail[0].is_finished == false {
            
            finishedDrawingView = FinishedDrawingView(
                resultImage: userPhoto,
                similarityValue: similarityScore ?? 0
                
            )
//        }else{
//            print("drawDetail[0].finished_image",drawDetail[0].finished_image)
//            let fileURL = getDocumentsDirectory().appendingPathComponent(drawDetail[0].finished_image!)
//            let photo = UIImage(contentsOfFile: fileURL.path)
//            finishedDrawingView = FinishedDrawingView(
//                resultImage: photo!,
//                similarityValue: similarityScore ?? 0
//                
//            )
//        }
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
        saveProgress()
        navigateToHome()
    }
    
    func finishedDrawingViewDidTapDone(_ view: FinishedDrawingView) {
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
        guard drawDetails.first != nil else {
            print("❌ No draw found with ID: \(drawID)")
            return
        }
        
        let finishedImagePath = generateFinishedImagePath()
        let fileURL = getDocumentsDirectory().appendingPathComponent(finishedImagePath!)
        // Convert the image to PNG data
        guard let imageData = userPhoto.pngData() else {
            print("❌ Failed to convert image to PNG")
            return
        }

        do {
            try imageData.write(to: fileURL)
            print("✅ Image saved at \(fileURL.path)")
        } catch {
            print("❌ Failed to save image: \(error.localizedDescription)")
            return
        }
        
//        let save =
        drawService.setFinishedDraw(draw_id: drawID, similarity_score: similarityScore!, finished_image: finishedImagePath!)
    }
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
//    private func calculateSimilarityScore() -> Int {
//        // TODO: Implement your similarity calculation logic here
//        // For now, return a random score between 60-95
//        return Int.random(in: 60...95)
//    }
    
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
