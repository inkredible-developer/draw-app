//
//  FinishedDrawingViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit

class ListFinishedDrawingViewController: UIViewController {
    var router: MainFlowRouter?
    var drawData: Draw
    private let drawService = DrawService()
    private var finishedDraws: [Draw] = []
    private var finishedDrawsWithAngles: [DrawWithAngle] = []
    private let presetNames = ["Front", "Side Left", "Quarter", "Side Right", "Top"]
    private var filterPreset: String? = nil
    
    

    private let listFinishedDrawingView = ListFinishedDrawingView()
    
    init(drawData: Draw) {
        self.drawData = drawData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        listFinishedDrawingView.delegate = self
        // Default filter to the preset of the selected draw
        if let angleId = drawData.angle_id as UUID? {
            if let match = drawService.getFinishedDraws().first(where: { $0.angle.angle_id == angleId }) {
                let angleName = match.angle.angle_name ?? "Custom"
                filterPreset = presetNames.contains(angleName) ? angleName : "Custom"
                print("🔍 Setting initial filter to: \(filterPreset ?? "nil") for angle: \(angleName)")
            }
        }
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
//        navigationItem.leftBarButtonItem = backBarButton
        
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
    
    private func groupedDrawsByPreset(_ draws: [DrawWithAngle]) -> [(preset: String, draw: DrawWithAngle)] {
        return draws.map { drawWithAngle in
            let name = drawWithAngle.angle.angle_name ?? "Custom"
            // Group all custom angles under "Custom" preset, but keep the original data for gallery
            let preset = presetNames.contains(name) ? name : "Custom"
            return (preset, drawWithAngle)
        }
    }
    
    private func loadFinishedDraws() {
        // Load all finished drawings from Core Data
        let allDraws = drawService.getFinishedDraws()
        print("🔍 All draws count: \(allDraws.count)")
        allDraws.forEach { draw in
            print("  - Draw ID: \(draw.draw.draw_id), Angle: \(draw.angle.angle_name ?? "nil")")
        }
        
        let filteredDraws: [DrawWithAngle]
        if let preset = filterPreset {
            print("🔍 Filtering by preset: \(preset)")
            if preset == "Custom" {
                // For Custom preset, show all custom angles (names starting with "Custom")
                filteredDraws = allDraws.filter { 
                    let angleName = $0.angle.angle_name ?? ""
                    let isCustom = angleName.hasPrefix("Custom") || !presetNames.contains(angleName)
                    print("  - Angle: \(angleName), isCustom: \(isCustom)")
                    return isCustom
                }
            } else {
                // For preset angles, filter by exact name
                filteredDraws = allDraws.filter { ($0.angle.angle_name ?? "") == preset }
            }
        } else {
            // If no filter, group by preset and show all
            let grouped = groupedDrawsByPreset(allDraws)
            // Get the first group's draws (this will be the preset of the current draw)
            if let firstGroup = grouped.first {
                let groupPreset = firstGroup.preset
                if groupPreset == "Custom" {
                    // Show all custom angles
                    filteredDraws = allDraws.filter { 
                        let angleName = $0.angle.angle_name ?? ""
                        return angleName.hasPrefix("Custom") || !presetNames.contains(angleName)
                    }
                } else {
                    // Show all angles of this preset
                    filteredDraws = allDraws.filter { ($0.angle.angle_name ?? "") == groupPreset }
                }
            } else {
                filteredDraws = allDraws
            }
        }
        
        print("🔍 Filtered draws count: \(filteredDraws.count)")
        filteredDraws.forEach { draw in
            print("  - Filtered Draw ID: \(draw.draw.draw_id), Angle: \(draw.angle.angle_name ?? "nil")")
        }
        
        finishedDraws = filteredDraws.map { $0.draw }
        finishedDrawsWithAngles = filteredDraws
        updateGalleryWithFinishedDraws()
        listFinishedDrawingView.updateFinishedDrawings(finishedDrawsWithAngles)
    }
    
    private func updateGalleryWithFinishedDraws() {
        print(" run updateGalleryWithFinishedDraws")
        let galleryImages = finishedDrawsWithAngles.compactMap { drawWithAngle -> UIImage? in
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
        
        // Find the index of the current draw in the finished draws array
        if let index = finishedDrawsWithAngles.firstIndex(where: { $0.draw.draw_id == drawData.draw_id }) {
            listFinishedDrawingView.selectedIndex = index
            listFinishedDrawingView.galleryCollectionView.reloadData()
        }
        
        // Update the view with actual draw data
        listFinishedDrawingView.similarityValue = Int(drawData.similarity_score)
        
        // Update other labels with actual data
        updateLabels(with: drawData)
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
        
        // Update detail label to show preset name
        if let angleName = finishedDrawsWithAngles.first(where: { $0.draw.draw_id == draw.draw_id })?.angle.angle_name {
            let preset = presetNames.contains(angleName) ? angleName : "Custom"
            listFinishedDrawingView.detailContainerLabel.text = "\(preset) Preset"
        } else {
            listFinishedDrawingView.detailContainerLabel.text = "Custom"
        }
    }

    private func updateDetailForSelectedIndex() {
        // Get the selected finished draw
        guard listFinishedDrawingView.selectedIndex < finishedDrawsWithAngles.count else { return }
        let selectedDrawWithAngle = finishedDrawsWithAngles[listFinishedDrawingView.selectedIndex]
        
        // Update similarity value with actual data
        listFinishedDrawingView.similarityValue = Int(selectedDrawWithAngle.draw.similarity_score)
        
        // Update other details for the selected drawing
        updateLabels(with: selectedDrawWithAngle.draw)
    }

    // Public method to update the filter and reload
    func setFilterPreset(_ preset: String?) {
        self.filterPreset = preset
        loadFinishedDraws()
        loadDrawData()
        updateDetailForSelectedIndex()
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
