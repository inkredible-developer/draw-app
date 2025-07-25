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
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
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
        
        segmentedControl.selectedSegmentTintColor = UIColor(named: "Inkredible-Green")
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        
        cardStackView.axis = .horizontal
        cardStackView.spacing = 16
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
            scrollView.heightAnchor.constraint(equalToConstant: 250),
            
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
        
        let presetNames = ["Front", "Side Left", "Quarter", "Side Right", "Top"]
        var items: [DrawWithAngle] = []
        if index == 0, let finishedDraws = allDraws?.finishedDraws {
            // For each preset, keep only the latest (by draw_id)
            for preset in presetNames {
                if let drawWithAngle = finishedDraws
                    .filter({ $0.angle.angle_name == preset })
                    .sorted(by: { $0.draw.draw_id.uuidString > $1.draw.draw_id.uuidString })
                    .first {
                    items.append(drawWithAngle)
                }
            }
            // For custom, keep only the latest custom (by draw_id)
            let customDraws = finishedDraws.filter { draw in
                guard let name = draw.angle.angle_name else { return false }
                return !presetNames.contains(name)
            }
            if let latestCustom = customDraws
                .sorted(by: { $0.draw.draw_id.uuidString > $1.draw.draw_id.uuidString })
                .first {
                items.append(latestCustom)
            }
        } else {
            items = allDraws?.unfinishedDraws ?? []
        }
        let segmentTitle = segmentedControl.titleForSegment(at: index) ?? "Draw"
        let capitalized = segmentTitle.prefix(1).capitalized + segmentTitle.dropFirst()
        emptyStateLabel.text = "Your \(capitalized) is Empty"
        
        guard !items.isEmpty else {
            scrollView.isHidden = true
            emptyStateView.isHidden = false
            return
        }
        
        scrollView.isHidden = false
        emptyStateView.isHidden = true
        
        for drawWithAngle in items {
            let draw = drawWithAngle.draw
            let angleName = drawWithAngle.angle.angle_name ?? "Unknown"
            var sketch = UIImage(named: "Sketch")
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(drawWithAngle.lastStep.image!)
            if FileManager.default.fileExists(atPath: fileURL.path),
                let data = try? Data(contentsOf: fileURL),
                let image = UIImage(data: data) {
                sketch = zoomImage(image, scale: 0.25)
            }
            
            let card = makeCard(sketch: sketch, angle_name: angleName, mode: draw.draw_mode!)
            let tag = draw.draw_id.hashValue
            
            card.tag = tag
            drawMap[tag] = draw
            
            card.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(drawCardTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            cardStackView.addArrangedSubview(card)
        }
    }
    func zoomImage(_ image: UIImage, scale: CGFloat) -> UIImage? {
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        // Use screen scale to avoid blurriness
        let screenScale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, screenScale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let zoomedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return zoomedImage
    }
    
    @objc private func drawCardTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag,
              let draw = drawMap[tag] else { return }
        //        print("test tap")
        //        print("draw",draw)
        delegate?.didTapDrawCard(draw: draw)
    }
    
    private func makeCard(sketch: UIImage?, angle_name: String, mode: String) -> UIView {
        
        let imageMode = mode == "reference" ? "reference_image" : "live_image"
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = angle_name
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
//        container.addSubview(titleLabel)

        // Card
        let card = UIView()
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = false
        card.backgroundColor = .white
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowOffset = CGSize(width: 0, height: 0)
        card.layer.shadowRadius = 2
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        // Sketch image
        let sketchImageView = UIImageView(image: sketch)
        sketchImageView.contentMode = .center
        sketchImageView.translatesAutoresizingMaskIntoConstraints = false
        sketchImageView.clipsToBounds = true
        card.addSubview(titleLabel)
        card.addSubview(sketchImageView)

        // Gradient View
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.clipsToBounds = true
        gradientView.layer.cornerRadius = 20
        card.insertSubview(gradientView, aboveSubview: sketchImageView)

        // Gradient Layer
        let gradientLayer = CAGradientLayer()

        let baseColor = UIColor(named: "Inkredible-DarkPurple") ?? UIColor(red: 127/255, green: 115/255, blue: 229/255, alpha: 1.0)

        gradientLayer.colors = [
            baseColor.withAlphaComponent(0.8).cgColor,
            baseColor.withAlphaComponent(0.2).cgColor,
            baseColor.withAlphaComponent(0.0).cgColor
        ]

        gradientLayer.locations = [0.0, 0.3, 0.5]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.cornerRadius = 20

        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)


        // Small Icon
        let smallIcon = UIImageView(image: UIImage(named: "\(imageMode)"))
        smallIcon.translatesAutoresizingMaskIntoConstraints = false
        smallIcon.contentMode = .scaleAspectFit
        smallIcon.layer.cornerRadius = 16
        smallIcon.clipsToBounds = true
        smallIcon.backgroundColor = .white
        card.addSubview(smallIcon)

        // Arrow Button
        let arrowButton = UIButton(type: .system)
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        arrowButton.tintColor = .black
        arrowButton.backgroundColor = UIColor(named: "Inkredible-Green") ?? UIColor(red: 127/255, green: 115/255, blue: 229/255, alpha: 1.0)
        arrowButton.layer.cornerRadius = 16
        card.addSubview(arrowButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),

            card.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            card.widthAnchor.constraint(equalToConstant: 180),
            card.heightAnchor.constraint(equalToConstant: 220),

            sketchImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 4),
            sketchImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            sketchImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            sketchImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: card.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            smallIcon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            smallIcon.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            smallIcon.widthAnchor.constraint(equalToConstant: 32),
            smallIcon.heightAnchor.constraint(equalToConstant: 32),

            arrowButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            arrowButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            arrowButton.widthAnchor.constraint(equalToConstant: 32),
            arrowButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Update gradient frame
        card.layoutIfNeeded()
        gradientLayer.frame = gradientView.bounds

        return container
    }






}
