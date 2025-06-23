//
//  CustomButton.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit

import UIKit

protocol CustomButtonDelegate: AnyObject {
  func customButtonDidTap(_ button: CustomButton)
}

final class CustomButton: UIButton {
  weak var delegate: CustomButtonDelegate?

  init(title: String) {
    super.init(frame: .zero)
    setupStyle(title: title)
  }
  required init?(coder: NSCoder) { fatalError() }

  private func setupStyle(title: String) {
    setTitle(title, for: .normal)
    setTitleColor(.black, for: .normal)
    backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
    titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
    layer.cornerRadius = 12
    translatesAutoresizingMaskIntoConstraints = false
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }

  @objc private func didTap() {
    delegate?.customButtonDidTap(self)
  }
    
}
