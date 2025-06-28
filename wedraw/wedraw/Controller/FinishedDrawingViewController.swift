//
//  FinishedDrawingViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit

class FinishedDrawingViewController: UIViewController, FinishedDrawingViewDelegate {
    var router: MainFlowRouter?
    private let finishedDrawingView = FinishedDrawingView()
    
    override func loadView() {
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
        navigationItem.rightBarButtonItem = finishButton
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
        // TODO: Add save progress logic here
        // This can include saving to Core Data, uploading to server, etc.
        print("Saving progress...")
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

#Preview {
    FinishedDrawingViewController()
}
