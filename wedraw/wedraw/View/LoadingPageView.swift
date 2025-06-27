//
//  LoadingPageView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//

import UIKit
import Lottie

protocol LoadingPageViewDelegate: AnyObject {
    
}

class LoadingPageView: UIView {
    
    private let animationView2 = LottieAnimationView(name: "loading-2", bundle: .main)
    private let animationView1 = LottieAnimationView(name: "scanner", bundle: .main)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor(named: "Inkredible-LightPurple")

        // Configure Lottie animation views
        [animationView1, animationView2].forEach { animationView in
            animationView.translatesAutoresizingMaskIntoConstraints = false
            animationView.loopMode = .loop
            animationView.play()
            addSubview(animationView)
        }

        // Layout: Stack vertically, centered
        NSLayoutConstraint.activate([
            animationView1.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView2.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView1.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            animationView2.topAnchor.constraint(equalTo: animationView1.bottomAnchor, constant: 24),
            animationView1.widthAnchor.constraint(equalToConstant: 120),
            animationView1.heightAnchor.constraint(equalToConstant: 120),
            animationView2.widthAnchor.constraint(equalToConstant: 120),
            animationView2.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    
}

#Preview {
    LoadingPageView()
}
