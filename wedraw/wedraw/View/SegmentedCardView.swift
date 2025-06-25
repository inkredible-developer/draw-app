//
//  SegmentedCardView.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

protocol SegmentedCardViewDelegate: AnyObject {
    func didTapDrawCard(draw:Draw)
}

class SegmentedCardView: UIView {
    
    
    weak var delegate: SegmentedCardViewDelegate?
    
    private var allDraws: DrawData?
    private var finishedDraws: [Draw] = []
    
    
    private let segmentedControl = UISegmentedControl(items: ["Finished Draw", "Unfinished Draw"])
    private let scrollView = UIScrollView()
    private let cardStackView = UIStackView()
    var drawMap: [Int: Draw] = [:]
    
    func configure(with allDraws: DrawData) {
        self.allDraws = allDraws
        loadCards(forSegment: segmentedControl.selectedSegmentIndex)
    }
    
    // Dynamic label for empty state
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Empty state with image + label
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let imageView = UIImageView(image: UIImage(named: "EmptyData")) // Make sure this is in Assets
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 160),
            imageView.heightAnchor.constraint(equalToConstant: 160),

            emptyStateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        loadCards(forSegment: 0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        loadCards(forSegment: 0)
    }
    
    private func setupView() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        
        cardStackView.axis = .horizontal
        cardStackView.spacing = 12
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(segmentedControl)
        addSubview(scrollView)
        scrollView.addSubview(cardStackView)
        addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 160),
            
            cardStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            cardStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            cardStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            cardStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            cardStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        loadCards(forSegment: sender.selectedSegmentIndex)
    }
    
    private func loadCards(forSegment index: Int) {
        cardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let items = index == 0 ? allDraws?.fineshedDraws : allDraws?.unfineshedDraws
        let segmentTitle = segmentedControl.titleForSegment(at: index) ?? "Draw"
        let capitalized = segmentTitle.prefix(1).capitalized + segmentTitle.dropFirst()
        emptyStateLabel.text = "Your \(capitalized) is Empty"
        
        guard let items = items, !items.isEmpty else {
            scrollView.isHidden = true
            emptyStateView.isHidden = false
            return
        }
        
        scrollView.isHidden = false
        emptyStateView.isHidden = true
        
        for draw in items {
            let icon = UIImage(named: "icon_head")
            let sketch = UIImage(named: "Sketch")
            let card = makeCard(icon: icon, sketch: sketch)
            let tag = draw.draw_id.hashValue
            
            card.tag = tag
            drawMap[tag] = draw
            
//            card.draw = draw
//            card.data = draw.draw_id
            card.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(drawCardTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            cardStackView.addArrangedSubview(card)
        }
    }
    @objc private func drawCardTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag,
        let draw = drawMap[tag] else { return }
//        print("test tap")
//        print("draw",draw)
        delegate?.didTapDrawCard(draw: draw)
    }
    
    private func makeCard(icon: UIImage?, sketch: UIImage?) -> UIView {
        let card = UIView()
//        var draw: Draw?
        card.backgroundColor = .clear
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: 160).isActive = true
        card.heightAnchor.constraint(equalToConstant: 220).isActive = true

        // Sketch image as background
        let sketchImageView = UIImageView(image: sketch)
        sketchImageView.translatesAutoresizingMaskIntoConstraints = false
        sketchImageView.contentMode = .scaleAspectFill
        sketchImageView.clipsToBounds = true
        sketchImageView.layer.borderColor = UIColor.lightGray.cgColor
        sketchImageView.layer.borderWidth = 2.0
        card.addSubview(sketchImageView)

        // Gradient overlay (optional)
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.backgroundColor = .clear

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.0).cgColor,
                                UIColor.systemPurple.withAlphaComponent(0.3).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        card.addSubview(gradientView)

        // Icon (top-left)
        let iconImageView = UIImageView(image: icon)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        card.addSubview(iconImageView)

        // Arrow button (bottom-right)
        let arrowButton = UIButton(type: .system)
        arrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        arrowButton.tintColor = .black
        arrowButton.backgroundColor = UIColor(red: 0.84, green: 1.0, blue: 0.75, alpha: 1.0) // soft green
        arrowButton.layer.cornerRadius = 20
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowButton)

        // Constraints
        NSLayoutConstraint.activate([
            sketchImageView.topAnchor.constraint(equalTo: card.topAnchor),
            sketchImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            sketchImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            sketchImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: card.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            iconImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            arrowButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            arrowButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            arrowButton.widthAnchor.constraint(equalToConstant: 40),
            arrowButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Make sure gradient layer resizes
        gradientView.layoutIfNeeded()
        gradientLayer.frame = card.bounds

        return card
    }


}
