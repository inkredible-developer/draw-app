//
//  FinishedDrawingView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit

protocol ListFinishedDrawingViewDelegate: AnyObject {
    func listFinishedDrawingView(_ view: ListFinishedDrawingView, didSelectImageAt index: Int)
}

class ListFinishedDrawingView: UIView {
    let imageView = UIImageView()
    let bottomContainerView = UIView()
    let detailContainerLabel = UILabel()
    let similarityTitleLabel = UILabel()
    let similarityValueLabel = UILabel()
    let divider = UIView()
    let createdOnTitleLabel = UILabel()
    let createdOnValueLabel = UILabel()
    let uploadedTimeTitleLabel = UILabel()
    let uploadedTimeValueLabel = UILabel()
    let similarityBackgroundView = UIView()
    
    var galleryImages: [UIImage] = Array(repeating: UIImage(named: "upl_1")!, count: 10)
    var selectedIndex: Int = 0
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 40, height: 54)
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .zero
        collectionView.decelerationRate = .fast
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
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
    
    weak var delegate: ListFinishedDrawingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "upl_1")
        addSubview(imageView)
        
        addSubview(galleryCollectionView)
        
        bottomContainerView.backgroundColor = UIColor(named: "Inkredible-DarkPurple") ?? .systemPurple
        bottomContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainerView.layer.masksToBounds = true
        bottomContainerView.layer.cornerRadius = 12
        addSubview(bottomContainerView)
        
        detailContainerLabel.text = "Detail"
        detailContainerLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)

        detailContainerLabel.adjustsFontForContentSizeCategory = true
        detailContainerLabel.textColor = .white
        detailContainerLabel.textAlignment = .left
        
        similarityTitleLabel.text = "Similarity towards reference image"
        similarityTitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)

        similarityTitleLabel.adjustsFontForContentSizeCategory = true
        similarityTitleLabel.textColor = .white
        similarityTitleLabel.textAlignment = .left
        
        similarityValueLabel.text = "78%"
        similarityValueLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .semibold)

        similarityValueLabel.textColor = UIColor(named: "Inkredible-Green") ?? .systemGreen
        
        
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        
        createdOnTitleLabel.text = "Created on"
        createdOnTitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        createdOnTitleLabel.textColor = .white
        createdOnValueLabel.text = "Thursday, 22 May 2025"
        createdOnValueLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        createdOnValueLabel.textColor = .black
        
        uploadedTimeTitleLabel.text = "Uploaded Time"
        uploadedTimeTitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        uploadedTimeTitleLabel.textColor = .white
        
        uploadedTimeValueLabel.text = "12.35"
        uploadedTimeValueLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        uploadedTimeValueLabel.textColor = .black
        
        bottomContainerView.addSubview(similarityBackgroundView)
        
        [detailContainerLabel, similarityTitleLabel, similarityBackgroundView, similarityValueLabel, divider, createdOnTitleLabel, createdOnValueLabel, uploadedTimeTitleLabel, uploadedTimeValueLabel].forEach { bottomContainerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        detailContainerLabel.translatesAutoresizingMaskIntoConstraints = false
        similarityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        similarityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        similarityBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        createdOnTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        createdOnValueLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadedTimeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadedTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            galleryCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            galleryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            galleryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            galleryCollectionView.heightAnchor.constraint(equalToConstant: 54),
            imageView.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 8),
            
            // Bottom container
            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 216),
            
            detailContainerLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 24),
            detailContainerLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),

            
            // Divider
            divider.topAnchor.constraint(equalTo: detailContainerLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            divider.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Similarity Title
            similarityTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            similarityTitleLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            similarityValueLabel.centerYAnchor.constraint(equalTo: similarityTitleLabel.centerYAnchor),
            similarityValueLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24),
                        
            // Created On
            createdOnTitleLabel.topAnchor.constraint(equalTo: similarityTitleLabel.bottomAnchor, constant: 16),
            createdOnTitleLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            createdOnValueLabel.centerYAnchor.constraint(equalTo: createdOnTitleLabel.centerYAnchor),
            createdOnValueLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24),
            
            // Uploaded Time
            uploadedTimeTitleLabel.topAnchor.constraint(equalTo: createdOnTitleLabel.bottomAnchor, constant: 12),
            uploadedTimeTitleLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 24),
            uploadedTimeValueLabel.centerYAnchor.constraint(equalTo: uploadedTimeTitleLabel.centerYAnchor),
            uploadedTimeValueLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -24),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth: CGFloat = 40
            let sideInset = max((galleryCollectionView.bounds.width - cellWidth) / 2, 0)
            layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        }
    }
    
    func updateGalleryImages(_ images: [UIImage]) {
        galleryImages = images
        galleryCollectionView.reloadData()
        
        if !images.isEmpty && selectedIndex < images.count {
            imageView.image = images[selectedIndex]
        }
    }
}

extension ListFinishedDrawingView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.imageView.image = galleryImages[indexPath.item]
        cell.layer.borderWidth = (indexPath.item == selectedIndex) ? 2 : 0
        cell.layer.borderColor = (indexPath.item == selectedIndex) ? UIColor.systemPurple.cgColor : UIColor.clear.cgColor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        imageView.image = galleryImages[selectedIndex]
        delegate?.listFinishedDrawingView(self, didSelectImageAt: selectedIndex)
        collectionView.reloadData()
    }
}

class GalleryCell: UICollectionViewCell {
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#Preview {
    ListFinishedDrawingView()
}
