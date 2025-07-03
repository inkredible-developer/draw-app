//
//  CustomIconButtonView.swift
//  wedraw
//
//  Created by Ali An Nuur on 23/06/25.
//

import UIKit

protocol CustomIconButtonViewDelegate: AnyObject {
    func didTapCustomViewButton(_ button: CustomIconButtonView)
}

class CustomIconButtonView: UIButton {
    // MARK: - Properties
    weak var delegate: CustomIconButtonViewDelegate?
    private var iconName: String?
    private var iconScale: CGFloat = 0.6
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    convenience init(iconName: String, iconColor: UIColor, backgroundColor: UIColor, width: CGFloat = 40, iconScale: CGFloat = 0.6) {
        self.init(frame: .zero)
        self.iconName = iconName
        self.iconScale = iconScale
        
        // Set width and height constraints
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: width).isActive = true
        
        // Update corner radius based on width
        layer.cornerRadius = width / 2
        
        configure(iconName: iconName, iconColor: iconColor, backgroundColor: backgroundColor)
    }
    
    // MARK: - Setup
    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
       
    }
    
    func configure(iconName: String, iconColor: UIColor, backgroundColor: UIColor) {
        self.iconName = iconName
        let image = UIImage(systemName: iconName)
        setImage(image, for: .normal)
        tintColor = iconColor
        self.backgroundColor = backgroundColor
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateIconSize()
    }
    
    private func updateIconSize() {
        guard let iconName = self.iconName else { return }
        
        if #available(iOS 13.0, *) {
            // Calculate desired icon size based on button dimensions
            let buttonSize = min(bounds.width, bounds.height)
            let desiredIconSize = buttonSize * iconScale
            
            // Create configuration with the desired size
            let config = UIImage.SymbolConfiguration(scale: getSymbolScale(for: iconScale))
            let resizedImage = UIImage(systemName: iconName)?.withConfiguration(config)
            
            // Critical fix: Use setImage instead of configuration on iOS 15+
            setImage(resizedImage, for: .normal)
            
            // Center the image
            contentEdgeInsets = UIEdgeInsets(
                top: (bounds.height - desiredIconSize) / 2,
                left: (bounds.width - desiredIconSize) / 2,
                bottom: (bounds.height - desiredIconSize) / 2,
                right: (bounds.width - desiredIconSize) / 2
            )
        }
    }
    
    private func getSymbolScale(for scale: CGFloat) -> UIImage.SymbolScale {
        if scale <= 0.4 {
            return .small
        } else if scale >= 0.8 {
            return .large
        } else {
            return .medium
        }
    }
    
    @objc private func buttonTapped() {
        // Add debug to verify this gets called
        print("CustomIconButtonView tapped: \(self.iconName ?? "unknown")")
        delegate?.didTapCustomViewButton(self)
    }
    
    func updateSize(width: CGFloat) {
        constraints.forEach { constraint in
            if (constraint.firstAttribute == .width || constraint.firstAttribute == .height) &&
                constraint.firstItem === self {
                removeConstraint(constraint)
            }
        }
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: width).isActive = true
        layer.cornerRadius = width / 2
        setNeedsLayout()
    }
    
    func updateIconScale(_ scale: CGFloat) {
        self.iconScale = scale
        setNeedsLayout()
    }
}
