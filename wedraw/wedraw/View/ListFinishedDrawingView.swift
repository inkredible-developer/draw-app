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
    var finishedDrawings: [DrawWithAngle] = []
    
    // Gesture properties
    private var panGesture: UIPanGestureRecognizer!
    private var initialTouchPoint: CGPoint = .zero
    private var hasTriggeredGesture = false
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 40, height: 53)
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
        
        // Configure imageView
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "upl_1")
        addSubview(imageView)
        
        addSubview(galleryCollectionView)
        
        bottomContainerView.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
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

        similarityValueLabel.textColor = UIColor(named: "Inkredible-Green")
        
        
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
        
        setupPanGesture()
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
            
            // ImageView constraints
            imageView.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 510),

            
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
    
    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true
//        print("Pan gesture setup complete")
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: imageView)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = gesture.location(in: imageView)
            hasTriggeredGesture = false
//            print("Pan gesture began at: \(initialTouchPoint)")
            
        case .changed:
            // Only trigger once per gesture
            if !hasTriggeredGesture {
                // Check if horizontal movement is significant
                if abs(translation.x) > abs(translation.y) && abs(translation.x) > 100 {
                    hasTriggeredGesture = true
//                    print("Horizontal swipe detected: \(translation.x)")
                    
                    if translation.x > 0 {
                        // Swipe right - go to previous drawing
                        if selectedIndex > 0 {
                            selectedIndex -= 1
//                            print("Going to previous drawing: \(selectedIndex)")
                            performSlideTransition(direction: .right)
                        } else {
//                            print("Already at first drawing")
                            // Add bounce animation
                            performBounceAnimation()
                        }
                    } else {
                        // Swipe left - go to next drawing
                        if selectedIndex < finishedDrawings.count - 1 {
                            selectedIndex += 1
//                            print("Going to next drawing: \(selectedIndex)")
                            performSlideTransition(direction: .left)
                        } else {
//                            print("Already at last drawing")
                            // Add bounce animation
                            performBounceAnimation()
                        }
                    }
                }
            }
            
        case .ended, .cancelled:
            hasTriggeredGesture = false
//            print("Pan gesture ended")
            
        default:
            break
        }
    }
    
    private enum SlideDirection {
        case left, right
    }
    
    private func performSlideTransition(direction: SlideDirection) {
        // Store current image
        let currentImage = imageView.image
        
        // Create a temporary image view for the transition
        let tempImageView = UIImageView()
        tempImageView.contentMode = imageView.contentMode
        tempImageView.clipsToBounds = imageView.clipsToBounds
        tempImageView.image = currentImage
        tempImageView.frame = imageView.frame
        addSubview(tempImageView)
        
        // Set up the new image view position
        let screenWidth = bounds.width
        let startX: CGFloat
        let endX: CGFloat
        
        switch direction {
        case .left:
            // New image slides in from right
            startX = screenWidth
            endX = -screenWidth
        case .right:
            // New image slides in from left
            startX = -screenWidth
            endX = screenWidth
        }
        
        // Position the new image view off-screen
        imageView.frame.origin.x = startX
        
        // Load the new drawing data
        loadDrawing(at: selectedIndex)
        updateGallerySelection()
        
        // Animate the transition
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            // Slide current image out
            tempImageView.frame.origin.x = endX
            // Slide new image in
            self.imageView.frame.origin.x = 0
        }) { _ in
            // Clean up
            tempImageView.removeFromSuperview()
            // Reset imageView frame to use constraints
            self.imageView.frame = self.imageView.frame
        }
    }
    
    private func performBounceAnimation() {
        // Create a subtle bounce animation
        UIView.animate(withDuration: 0.1, animations: {
            self.imageView.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform(translationX: -10, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.imageView.transform = .identity
                })
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // Calculate center inset to keep selected item centered
            let cellWidth: CGFloat = 40
            let selectedCellWidth = cellWidth * 1.2 // Account for selected cell being larger
            let sideInset = max((galleryCollectionView.bounds.width - selectedCellWidth) / 2, 0)
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
    
    func updateFinishedDrawings(_ drawings: [DrawWithAngle]) {
//        print("updateFinishedDrawings: Received \(drawings.count) drawings")
        finishedDrawings = drawings
        if !drawings.isEmpty {
//            print("updateFinishedDrawings: Loading initial drawing at index \(selectedIndex)")
            loadDrawing(at: selectedIndex)
            updateGallerySelection()
        } else {
            print("updateFinishedDrawings: No drawings to load")
        }
    }
    
    private func loadDrawing(at index: Int) {
        guard index >= 0 && index < finishedDrawings.count else { 
            print("loadDrawing: Invalid index \(index), count: \(finishedDrawings.count)")
            return 
        }
        
//        print("loadDrawing: Loading drawing at index \(index)")
        let drawing = finishedDrawings[index]
        
        // Update the imageView later
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(drawing.draw.finished_image!)
        let photo = UIImage(contentsOfFile: fileURL.path)
        imageView.image = photo
//        imageView.image = UIImage(named: "upl_1") // Placeholder image
        similarityValue = Int(drawing.draw.similarity_score)
        
        //created_at cek lagi
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        createdOnValueLabel.text = formatter.string(from: Date())
        
        // Update uploaded time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        uploadedTimeValueLabel.text = timeFormatter.string(from: Date())
        
        delegate?.listFinishedDrawingView(self, didSelectImageAt: index)
//        print("loadDrawing: Drawing loaded successfully")
    }
    
    // MARK: - Gallery Centering Methods
    
    private func centerSelectedItem() {
        guard selectedIndex >= 0 && selectedIndex < finishedDrawings.count else { return }
        
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        galleryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func updateGallerySelection() {
        galleryCollectionView.reloadData()
        centerSelectedItem()
    }
}

extension ListFinishedDrawingView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finishedDrawings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.imageView.image = galleryImages[indexPath.item]
        
        // Update cell appearance based on selection
        let isSelected = indexPath.item == selectedIndex
        cell.layer.borderWidth = isSelected ? 3 : 0
        cell.layer.borderColor = isSelected ? UIColor.systemPurple.cgColor : UIColor.clear.cgColor
        
        // Make selected cell larger
        let scale: CGFloat = isSelected ? 1.2 : 1.0
        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        imageView.image = galleryImages[selectedIndex]
        delegate?.listFinishedDrawingView(self, didSelectImageAt: selectedIndex)
        updateGallerySelection()
    }
}

extension ListFinishedDrawingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == imageView
    }
}

class GalleryCell: UICollectionViewCell {
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
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
//
//#Preview {
//    ListFinishedDrawingView()
//}
