//
//  FinishedDrawingViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit

class ListFinishedDrawingViewController: UIViewController {
    var router: MainFlowRouter?

    private let listFinishedDrawingView = ListFinishedDrawingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        listFinishedDrawingView.delegate = self

        updateDetailForSelectedIndex()
    }
    
    override func loadView() {
        view = listFinishedDrawingView
    }
    
    private func setupNavigationBar() {
        let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        backBarButton.tintColor = UIColor(named: "Inkredible-DarkPurple")
        navigationItem.leftBarButtonItem = backBarButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.tintColor = UIColor(named: "Inkredible-DarkPurple")
        navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        // Save work logic can be added here
        saveWork()
        navigateToHome()
    }
    
    private func saveWork() {
        // TODO: Add save work logic here
        // This can include saving to Core Data, uploading to server, etc.
        print("Saving work...")
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

    private func updateDetailForSelectedIndex() {
        listFinishedDrawingView.similarityValue = 25 + listFinishedDrawingView.selectedIndex * 10
        
        //update logicnya
        
    }
}

extension ListFinishedDrawingViewController: ListFinishedDrawingViewDelegate {
    func listFinishedDrawingView(_ view: ListFinishedDrawingView, didSelectImageAt index: Int) {
        updateDetailForSelectedIndex()
    }
}

#Preview {
    ListFinishedDrawingView()
}
