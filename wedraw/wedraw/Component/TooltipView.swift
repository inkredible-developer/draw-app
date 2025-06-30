//
//  TooltipView.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit

final class TooltipView: UIView {
    private let label = UILabel()
    private var dismissHandler: (() -> Void)?
    private var tapGesture: UITapGestureRecognizer?
    
    init(text: String, dismissHandler: (() -> Void)? = nil) {
        self.dismissHandler = dismissHandler
        super.init(frame: .zero)
        backgroundColor = UIColor(named: "Inkredible-DarkText")
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        setupLabel(with: text)
        setupTapGestureRecognizer()
    }
    
    private func setupLabel(with text: String) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32)
        ])
    }
    
    private func setupTapGestureRecognizer() {
        if let window = getKeyWindow() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
            tapGesture.cancelsTouchesInView = false
            window.addGestureRecognizer(tapGesture)
            self.tapGesture = tapGesture
        }
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !self.bounds.contains(location) {
            self.removeFromSuperview()
            dismissHandler?()
        }
    }
    
    override func removeFromSuperview() {
        if let gesture = tapGesture, let window = getKeyWindow() {
            window.removeGestureRecognizer(gesture)
            tapGesture = nil
        }
        super.removeFromSuperview()
    }
    
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 15, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
