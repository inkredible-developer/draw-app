//
//  ObjectListView.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

class ObjectListView: UIView {
    let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Every Line Starts a Journey"
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    var learnMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Learn More", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .semibold)
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bannerLabel: UILabel = {
        let label = UILabel()
        label.text = "Loomis Method"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    lazy var bannerCard: UIView = {
        let card = UIView()
        card.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Circle view
        let circleView = UIView()
        circleView.backgroundColor = .lightGray
        circleView.layer.cornerRadius = 75
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView()
        image.image = UIImage(named: "HeadHome") // must match Assets name
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let title = UILabel()
        title.text = "The Loomis Method: Building Head Structures"
        title.font = UIFont.preferredFont(forTextStyle: .callout)
        
        
        title.textColor = UIColor.white
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel()
        description.text = "Learn how to style the proportions and volume of the human head with simple steps"
        description.font = UIFont.preferredFont(forTextStyle: .caption2)
        description.textColor = UIColor.white
        description.numberOfLines = 0
        description.translatesAutoresizingMaskIntoConstraints = false
        
        
        card.addSubview(image)
        card.addSubview(title)
        card.addSubview(description)
        card.addSubview(learnMoreButton)
        
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            image.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.heightAnchor.constraint(equalToConstant: 120),
            
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            description.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            description.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            description.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            
            learnMoreButton.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 8),
            learnMoreButton.leadingAnchor.constraint(equalTo: description.leadingAnchor),
            learnMoreButton.widthAnchor.constraint(equalToConstant: 86),
            learnMoreButton.heightAnchor.constraint(equalToConstant: 24),
            
        ])
        
        return card
    }()
    
    // Horizontal scroll view for models
    let modelsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let modelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let sectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        
        let boldText = "Start Draw"
        let regularText = ", Select Your Heads Model !"
        
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title3).fontDescriptor.withSymbolicTraits(.traitBold) ?? UIFontDescriptor(), size: 0),
            .foregroundColor: UIColor.label
        ]
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .title3),
            .foregroundColor: UIColor.label
        ]
        
        let attributedText = NSMutableAttributedString(string: boldText, attributes: boldAttributes)
        attributedText.append(NSAttributedString(string: regularText, attributes: regularAttributes))
        
        label.attributedText = attributedText
        return label
        
    }()
}
