//
//  FinishedDrawingView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit

protocol FinishedDrawingViewDelegate: AnyObject {
    func finishedDrawingViewDidTapDone(_ view: FinishedDrawingView)
}

class FinishedDrawingView: UIView {
    weak var delegate: FinishedDrawingViewDelegate?
    
    let imageView = UIImageView()
    let bottomContainerView = UIView()
    let similarityTitleLabel = UILabel()
    let similarityValueLabel = UILabel()
    let divider = UIView()
    let divider2 = UIView()
    let createdOnTitleLabel = UILabel()
    let createdOnValueLabel = UILabel()
    let uploadedTimeTitleLabel = UILabel()
    let uploadedTimeValueLabel = UILabel()
    let similarityBackgroundView = UIView()
    
    var similarityValue: Int = 0 {
        didSet {
            similarityValueLabel.text = "\(similarityValue)%"
            if similarityValue <= 30 {
                similarityValueLabel.textColor = UIColor(named: "Inkredible-LightRed") ?? .systemRed
            } else {
                similarityValueLabel.textColor = UIColor(named: "Inkredible-Green") ?? .systemGreen
            }
        }
    }
    
    private var resultImage: UIImage
    private var createdDate: Date
    private var uploadedTime: String
    
    init(frame: CGRect = .zero, resultImage: UIImage, similarityValue: Int, createdDate: Date = Date(), uploadedTime: String = "") {
        self.resultImage = resultImage
        self.createdDate = createdDate
        
        // Format current time if not provided
        if uploadedTime.isEmpty {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            self.uploadedTime = timeFormatter.string(from: Date())
        } else {
            self.uploadedTime = uploadedTime
        }
        
        super.init(frame: frame)
        self.similarityValue = similarityValue
        setupView()
        setupConstraints()
        configureWithValues()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureWithValues() {
        // Set image
        imageView.image = resultImage
        
        // Set similarity value
        similarityValueLabel.text = "\(similarityValue)%"
        if similarityValue <= 30 {
            similarityValueLabel.textColor = UIColor(named: "Inkredible-LightRed") ?? .systemRed
        } else {
            similarityValueLabel.textColor = UIColor(named: "Inkredible-Green") ?? .systemGreen
        }
        
        // Format and set date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        createdOnValueLabel.text = dateFormatter.string(from: createdDate)
        
        // Set uploaded time
        uploadedTimeValueLabel.text = uploadedTime
    }
    
    private func setupView() {
        backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "upl_1")
        addSubview(imageView)
        
        
        bottomContainerView.backgroundColor = UIColor(named: "Inkredible-DarkPurple") ?? .systemPurple
        bottomContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainerView.layer.masksToBounds = true
        addSubview(bottomContainerView)
        
        similarityTitleLabel.text = "Similarity towards reference image"
        similarityTitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .semibold)
        
        similarityTitleLabel.adjustsFontForContentSizeCategory = true
        similarityTitleLabel.textColor = .white
        similarityTitleLabel.textAlignment = .center
        
        similarityValueLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .bold)
        
        similarityValueLabel.textColor = UIColor(named: "Inkredible-Green") ?? .systemGreen
        similarityValueLabel.textAlignment = .center
        
        similarityBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        similarityBackgroundView.layer.cornerRadius = 20
        similarityBackgroundView.layer.masksToBounds = true
        
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        divider2.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        createdOnTitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        createdOnTitleLabel.textColor = .white
        createdOnValueLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        createdOnValueLabel.textColor = .black
        
        uploadedTimeTitleLabel.text = "Uploaded Time"
        uploadedTimeTitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        uploadedTimeTitleLabel.textColor = .white
        
        uploadedTimeValueLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        uploadedTimeValueLabel.textColor = .black
        
        bottomContainerView.addSubview(similarityBackgroundView)
        
        [similarityTitleLabel, similarityBackgroundView, similarityValueLabel, divider, createdOnTitleLabel, createdOnValueLabel, divider2, uploadedTimeTitleLabel, uploadedTimeValueLabel].forEach { bottomContainerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        similarityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        similarityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        similarityBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider2.translatesAutoresizingMaskIntoConstraints = false
        createdOnTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        createdOnValueLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadedTimeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadedTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ImageView fills top area
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            
            
            // Bottom container
            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 267),
            
            // Similarity Title
            similarityTitleLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 24),
            similarityTitleLabel.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            
            // Similarity Value
            similarityValueLabel.topAnchor.constraint(equalTo: similarityTitleLabel.bottomAnchor, constant: 8),
            similarityValueLabel.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            
            similarityBackgroundView.centerXAnchor.constraint(equalTo: similarityValueLabel.centerXAnchor),
            similarityBackgroundView.centerYAnchor.constraint(equalTo: similarityValueLabel.centerYAnchor),
            similarityBackgroundView.leadingAnchor.constraint(equalTo: similarityValueLabel.leadingAnchor, constant: -12),
            similarityBackgroundView.trailingAnchor.constraint(equalTo: similarityValueLabel.trailingAnchor, constant: 12),
            similarityBackgroundView.topAnchor.constraint(equalTo: similarityValueLabel.topAnchor, constant: -6),
            similarityBackgroundView.bottomAnchor.constraint(equalTo: similarityValueLabel.bottomAnchor, constant: 6),
            
            
            // Divider
            divider.topAnchor.constraint(equalTo: similarityValueLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            divider.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Created On
            createdOnTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            createdOnTitleLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            createdOnValueLabel.centerYAnchor.constraint(equalTo: createdOnTitleLabel.centerYAnchor),
            createdOnValueLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24),
            
            // Divider2
            divider2.topAnchor.constraint(equalTo: createdOnTitleLabel.bottomAnchor, constant: 16),
            divider2.leadingAnchor.constraint(equalTo: createdOnTitleLabel.leadingAnchor, constant: 24),
            divider2.trailingAnchor.constraint(equalTo: createdOnTitleLabel.trailingAnchor, constant: -24),
            divider2.heightAnchor.constraint(equalToConstant: 1),
            
            // Uploaded Time
            uploadedTimeTitleLabel.topAnchor.constraint(equalTo: createdOnTitleLabel.bottomAnchor, constant: 12),
            uploadedTimeTitleLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            uploadedTimeValueLabel.centerYAnchor.constraint(equalTo: uploadedTimeTitleLabel.centerYAnchor),
            uploadedTimeValueLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24)
        ])
    }
}
