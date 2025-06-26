//
//  FinishedDrawingView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit

protocol FinishedDrawingViewDelegate: AnyObject {
    func chooseButtonTapped()
}

class FinishedDrawingView: UIView {
    weak var delegate: FinishedDrawingViewDelegate?
    
    let chooseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 16
        return button
    }()
    
    
    let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Inkredible-LightPurple")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        setupActions()
    }
        
    private func setupView() {
        backgroundColor = .white
        addSubview(bottomContainerView)
        bottomContainerView.addSubview(chooseButton)
                
    }
    
    private func setupConstraints() {
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            // Bottom Container
            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 267),

            // Choose Button
            chooseButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 44),
            chooseButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -55),
            chooseButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 32),
            chooseButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -32),
            
        ])
    }
    
    private func setupActions() {
        chooseButton.addTarget(self, action: #selector(chooseButtonTapped), for: .touchUpInside)
    }
    


    
    @objc private func chooseButtonTapped() {
        delegate?.chooseButtonTapped()
    }

}

#Preview {
    FinishedDrawingView()
}
