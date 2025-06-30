//
//  ObjectListView.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

protocol ObjectListViewDelegate: AnyObject {
    func didTapLearnMoreButton()
}

class ObjectListView: UIView {
    
    weak var delegate: ObjectListViewDelegate?
    
    let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Every Line Starts a Journey"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
        
    var learnMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Learn More", for: .normal)
        button.setTitleColor(.black, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .medium)
//        button.backgroundColor = UIColor.systemGreen
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Banner Title
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        learnMoreButton.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        learnMoreButton.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
    }
    
    @objc private func learnMoreTapped() {
        delegate?.didTapLearnMoreButton()
    }

    
    lazy var bannerCard: UIView = {
            let card = UIView()
            card.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
            card.layer.cornerRadius = 20
            card.translatesAutoresizingMaskIntoConstraints = false

            // Container for content
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
        

            let image = UIImageView()
            image.image = UIImage(named: "hed")
            image.contentMode = .scaleAspectFit
            image.translatesAutoresizingMaskIntoConstraints = false

            let title = UILabel()
            title.text = "The Loomis Method: Building Head Structures"
            title.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .bold)
            title.textColor = .white
            title.numberOfLines = 0
            title.translatesAutoresizingMaskIntoConstraints = false

            let description = UILabel()
            description.text = "Learn how to style the proportions and volume of the human head with simple steps"
            description.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
            description.textColor = .white
            description.numberOfLines = 0
            description.translatesAutoresizingMaskIntoConstraints = false

//            containerView.addSubview(image)
            containerView.addSubview(title)
            containerView.addSubview(description)
            containerView.addSubview(learnMoreButton)
            card.addSubview(containerView)
        card.addSubview(image)

        NSLayoutConstraint.activate([
            // Vertically center containerView in card
            containerView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: image.trailingAnchor),
            containerView.trailingAnchor.constraint(equalTo: card.trailingAnchor),

            image.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            image.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            image.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            image.widthAnchor.constraint(equalToConstant:90),
            image.heightAnchor.constraint(equalToConstant: 90),

            title.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            description.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            description.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            description.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            learnMoreButton.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 8),
            learnMoreButton.leadingAnchor.constraint(equalTo: description.leadingAnchor),
            learnMoreButton.widthAnchor.constraint(equalToConstant: 85),
            learnMoreButton.heightAnchor.constraint(equalToConstant: 25),
            learnMoreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
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

