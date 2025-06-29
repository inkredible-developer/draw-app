//
//  FinishedDrawingViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit

class ListFinishedDrawingViewController: UIViewController {
    var router: MainFlowRouter?
    var drawData: Draw?
    private let drawService = DrawService()
    private var finishedDraws: [DrawWithAngle] = []

    private let listFinishedDrawingView = ListFinishedDrawingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        listFinishedDrawingView.delegate = self
        loadFinishedDraws()
        loadDrawData()
        updateDetailForSelectedIndex()
    }
    
    override func loadView() {
        view = listFinishedDrawingView
    }
    
    private func setupNavigationBar() {
        let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        backBarButton.tintColor = UIColor(named: "Inkredible-DarkPurple")
        navigationItem.leftBarButtonItem = backBarButton
        
        // Commented out Done button
        // let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        // doneButton.tintColor = UIColor(named: "Inkredible-DarkPurple")
        // navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        saveWork()
        navigateToHome()
    }
    
    private func saveWork() {
        print("Saving work...")
    }
    
    private func navigateToHome() {
        if let router = router {
            router.navigateToRoot(animated: true)
        } else {
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
    
    private func loadFinishedDraws() {
        // Load all finished drawings from Core Data
        finishedDraws = drawService.getFinishedDraws()
        print("✅ Loaded \(finishedDraws.count) finished drawings from Core Data")
        
        updateGalleryWithFinishedDraws()
        listFinishedDrawingView.updateFinishedDrawings(finishedDraws)
    }
    
    private func updateGalleryWithFinishedDraws() {
        print(" run updateGalleryWithFinishedDraws")
        let galleryImages = finishedDraws.compactMap { drawWithAngle -> UIImage? in
            if let finishedImagePath = drawWithAngle.draw.finished_image {
                
                let fileURL = getDocumentsDirectory().appendingPathComponent(finishedImagePath)
                print("fileURL",fileURL)
                let photo = UIImage(contentsOfFile: fileURL.path)
                return photo
//                return UIImage(named: "upl_1") // Placeholder for now
            } else {
                return UIImage(named: "upl_1") // Default image
            }
        }
        listFinishedDrawingView.updateGalleryImages(galleryImages)
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func loadDrawData() {
        guard let draw = drawData else {
            print("❌ No draw data available")
            return
        }
        
        // Find the index of the current draw in the finished draws array
        if let index = finishedDraws.firstIndex(where: { $0.draw.draw_id == draw.draw_id }) {
            listFinishedDrawingView.selectedIndex = index
            listFinishedDrawingView.galleryCollectionView.reloadData()
        }
        
        // Update the view with actual draw data
        listFinishedDrawingView.similarityValue = Int(draw.similarity_score)
        
        // Update other labels with actual data
        updateLabels(with: draw)
    }
    
    private func updateLabels(with draw: Draw) {
        // Update similarity value
        listFinishedDrawingView.similarityValue = Int(draw.similarity_score)
        
        // Update creation date (you can format this as needed)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        // For now, use current date since we don't have creation date in the model
        listFinishedDrawingView.createdOnValueLabel.text = dateFormatter.string(from: Date())
        
        // Update uploaded time (you can format this as needed)
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        listFinishedDrawingView.uploadedTimeValueLabel.text = timeFormatter.string(from: Date())
        
        // Update main image if you have finished_image path
        if let finishedImagePath = draw.finished_image {
            // Load image from path (you'll need to implement this based on how you store images)
            // listFinishedDrawingView.imageView.image = UIImage(contentsOfFile: finishedImagePath)
        }
    }

    private func updateDetailForSelectedIndex() {
        // Get the selected finished draw
        guard listFinishedDrawingView.selectedIndex < finishedDraws.count else { return }
        let selectedDraw = finishedDraws[listFinishedDrawingView.selectedIndex]
        
        // Update similarity value with actual data
        listFinishedDrawingView.similarityValue = Int(selectedDraw.draw.similarity_score)
        
        // Update other details for the selected drawing
        updateLabels(with: selectedDraw.draw)
    }
}

extension ListFinishedDrawingViewController: ListFinishedDrawingViewDelegate {
    func listFinishedDrawingView(_ view: ListFinishedDrawingView, didSelectImageAt index: Int) {
        updateDetailForSelectedIndex()
    }
}

//#Preview {
//    ListFinishedDrawingView()
//}
