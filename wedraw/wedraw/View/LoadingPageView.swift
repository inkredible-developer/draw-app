//
//  LoadingPageView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit
import Lottie

class LoadingPageView: UIView {
    
    private var comparingLabel: UILabel = {
        let label = UILabel()
        label.text = "Comparing Your Result\nWith Reference Angle"
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
        label.numberOfLines = 2
        label.textColor = UIColor(named: "Inkredible-Green")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let animationView1: LottieAnimationView = {
        let animation = LottieAnimationView(name: "scanner", bundle: .main)
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()
    
    private let animationView2: LottieAnimationView = {
        let animation = LottieAnimationView(name: "loading-2", bundle: .main)
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        playAnimations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        playAnimations()
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "Inkredible-LightPurple")
        addSubview(containerView)
        containerView.addSubview(comparingLabel)
        containerView.addSubview(animationView1)
        containerView.addSubview(animationView2)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 350),

            comparingLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            comparingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            comparingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            animationView1.topAnchor.constraint(equalTo: comparingLabel.bottomAnchor),
            animationView1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView1.widthAnchor.constraint(equalToConstant: 310),
            
            animationView2.topAnchor.constraint(equalTo: animationView1.bottomAnchor, constant: 0),
            animationView2.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView2.widthAnchor.constraint(equalToConstant: 206),
            animationView2.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func playAnimations() {
        animationView1.animationSpeed = 0.5
        animationView2.animationSpeed = 0.5
        animationView1.play()
        animationView2.play()
    }
}

#Preview {
    LoadingPageView()
}
