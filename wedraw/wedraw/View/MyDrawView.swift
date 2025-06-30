//
//  MyDrawView.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

class MyDrawView: UIView {
    
    
    let recentLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Angle/Draw"
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Horizontal scroll view for recent
    let recentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var recentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let drawSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Finished Draw", "Unfinished Draw"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(white: 0.95, alpha: 1)
        control.selectedSegmentTintColor = .white
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)], for: .selected)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyData") // replace with your asset name
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Recent Draw Is Empty"
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupViews() {
        addSubview(recentLabel)
        addSubview(recentScrollView)
        addSubview(drawSegmentedControl)
        addSubview(emptyImageView)
        addSubview(emptyLabel)
        
        recentScrollView.addSubview(recentStackView)
        
        NSLayoutConstraint.activate([
            recentLabel.topAnchor.constraint(equalTo: topAnchor),
            recentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            recentScrollView.topAnchor.constraint(equalTo: recentLabel.bottomAnchor, constant: 12),
            recentScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            recentScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            recentScrollView.heightAnchor.constraint(equalToConstant: 160),
            
            recentStackView.leadingAnchor.constraint(equalTo: recentScrollView.contentLayoutGuide.leadingAnchor),
            recentStackView.trailingAnchor.constraint(equalTo: recentScrollView.contentLayoutGuide.trailingAnchor),
            recentStackView.topAnchor.constraint(equalTo: recentScrollView.contentLayoutGuide.topAnchor),
            recentStackView.bottomAnchor.constraint(equalTo: recentScrollView.contentLayoutGuide.bottomAnchor),
            recentStackView.heightAnchor.constraint(equalTo: recentScrollView.frameLayoutGuide.heightAnchor),
            
            drawSegmentedControl.topAnchor.constraint(equalTo: recentScrollView.bottomAnchor, constant: 20),
            drawSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            drawSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            drawSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            emptyImageView.topAnchor.constraint(equalTo: drawSegmentedControl.bottomAnchor, constant: 16),
            emptyImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 150),
            emptyImageView.heightAnchor.constraint(equalToConstant: 150),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
