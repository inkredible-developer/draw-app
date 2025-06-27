//
//  FinishedDrawingViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit

class FinishedDrawingViewController: UIViewController {
    var router: MainFlowRouter?

    private let finishedDrawingView = FinishedDrawingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        finishedDrawingView.similarityValue = 25
    }
    
    override func loadView() {
        view = finishedDrawingView
    }
    
    private func setupNavigationBar() {
        let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        doneBarButton.tintColor = UIColor(named: "Inkredible-DarkPurple")
        navigationItem.rightBarButtonItem = doneBarButton
    }

    @objc private func doneButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

#Preview {
    FinishedDrawingView()
}
