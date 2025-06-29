//
//  LoadingPageView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 27/06/25.
//
import UIKit
import DotLottie

class LoadingPageView: UIView {

    private let comparingLabel: UILabel = {
        let label = UILabel()
        label.text = "Comparing Your Result\nWith Reference Angle"
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
        label.numberOfLines = 2
        label.textColor = UIColor(named: "Inkredible-Green") ?? .systemGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let animationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    //    private let containerView: UIView = {
    //        let view = UIView()
    //        view.translatesAutoresizingMaskIntoConstraints = false
    //        return view
    //    }()

    private var dotLottieView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        playDotLottie()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        playDotLottie()
    }

    private func setupView() {
        backgroundColor = UIColor(named: "Inkredible-DarkPurple") ?? .black
        addSubview(animationContainer)
        animationContainer.addSubview(comparingLabel)

        NSLayoutConstraint.activate([
            
            animationContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationContainer.widthAnchor.constraint(equalToConstant: 250),
            animationContainer.heightAnchor.constraint(equalTo: animationContainer.widthAnchor),
            
            comparingLabel.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor),
            comparingLabel.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor),
            comparingLabel.bottomAnchor.constraint(equalTo: animationContainer.topAnchor, constant: -20),
        ])
    }

    private func playDotLottie() {
            dotLottieView?.removeFromSuperview()
            let anim = DotLottieAnimation(
                fileName: "scanner-new",
                config: AnimationConfig(autoplay: true, loop: true)
            )
        let view: UIView = anim.view()
            view.translatesAutoresizingMaskIntoConstraints = false
            animationContainer.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor),
                view.topAnchor.constraint(equalTo: animationContainer.topAnchor),
                view.bottomAnchor.constraint(equalTo: animationContainer.bottomAnchor)
            ])
            dotLottieView = view
        }
}

#Preview {
    LoadingPageView()
}
