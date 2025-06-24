//
//  SetAngleViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit

class SetAngleViewController: UIViewController {

    private let setAngleView = SetAngleView()
    private var isToastVisible = false
    private var dismissWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Your Angle"
        setupNavigationBar()
        setupView()
    }
    
    override func loadView() {
        view = setAngleView
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func setupView() {
        setAngleView.delegate = self
    }
}

extension SetAngleViewController: SetAngleViewDelegate {
    
    func infoButtonTapped() {
        if isToastVisible {
            dismissToast()
        } else {
            showToast()
        }
    }
    
    func chooseButtonTapped() {
        // Handle choose button action
        // Navigate to next screen or perform selection
        print("Choose button tapped")
    }
    
    func presetAngleButtonTapped() {
        // Handle preset angle button action
        print("Preset angle button tapped")
    }
        
    private func showToast() {
        isToastVisible = true
        setAngleView.showToast()
        
        dismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissToast()
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }
    
    private func dismissToast() {
        if !isToastVisible { return }
        
        dismissWorkItem?.cancel()
        setAngleView.hideToast()
        isToastVisible = false
    }
}
