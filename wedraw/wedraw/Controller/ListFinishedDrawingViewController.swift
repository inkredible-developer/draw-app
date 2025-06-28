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
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
