//
//  ModeCardView.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit
final class ModeCardView: UIView {
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        view.layer.cornerRadius = 20
        // Removed border from container
        return view
    }()
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()

    init(mode: DrawingMode) {
        super.init(frame: .zero)
        setupUI(mode: mode)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(mode: DrawingMode) {
        // Add container to self
        addSubview(container)
        
        // Configure main view with border
        backgroundColor = UIColor.clear
        layer.cornerRadius = 20
        layer.borderWidth = 2
            layer.borderColor = UIColor(named: "Inkredible-DarkPurple")?.cgColor ?? UIColor.systemPurple.cgColor
        clipsToBounds = true

        // Setup container constraints with padding
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        // Configure image view
        imageView.image = mode.image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        // Configure labels
        titleLabel.text = mode.title
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        descriptionLabel.text = mode.description
        descriptionLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        // Add subviews to container instead of self
        [titleLabel, imageView, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }

        // Create a more flexible layout that will adapt to different card sizes
        let contentStack = UIStackView(arrangedSubviews: [titleLabel, imageView, descriptionLabel])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.distribution = .equalSpacing
        contentStack.spacing = 30
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            contentStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            
            imageView.widthAnchor.constraint(equalTo: contentStack.widthAnchor, multiplier: 0.765),
            imageView.heightAnchor.constraint(equalTo: contentStack.widthAnchor),
            
            titleLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor)
        ])
    }
}
#Preview {
    ModeCardView(mode: .reference)
        
}
