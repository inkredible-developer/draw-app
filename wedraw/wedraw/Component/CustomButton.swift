//
//  CustomButton.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit

protocol CustomButtonDelegate: AnyObject {
    func customButtonDidTap(_ button: CustomButton)
}

final class CustomButton: UIButton {
    weak var delegate: CustomButtonDelegate?
    
    init(title: String = "Select", backgroundColor: UIColor = .systemGreen, titleColor: UIColor = .white) {
        super.init(frame: .zero)
        setupStyle(title: title, backgroundColor: backgroundColor, titleColor: titleColor)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupStyle(title: String, backgroundColor: UIColor, titleColor: UIColor) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    func updateAppearance(title: String? = nil, backgroundColor: UIColor? = nil, titleColor: UIColor? = nil) {
        if let title = title {
            setTitle(title, for: .normal)
        }
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        if let titleColor = titleColor {
            setTitleColor(titleColor, for: .normal)
        }
    }
    
    @objc private func didTap() {
        delegate?.customButtonDidTap(self)
    }
}
