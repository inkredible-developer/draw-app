//
//  PhotoCaptureSheetViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 26/06/25.
//


import UIKit

class PhotoCaptureSheetViewController: UIViewController {
    
var router: MainFlowRouter?

    // MARK: - UI Elements

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let closeButton = CustomIconButtonView(iconName: "xmark", iconColor: UIColor(named: "Inkredible-Red") ?? .systemRed, backgroundColor: UIColor(named: "Inkredible-DarkText") ?? .green, iconScale: 0.5)

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Snap of Photo To See How You Are Improving!"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "Your photo will be saved and you can see your progress on the main screen"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 15)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let skipButton: UIButton = {
        let b = UIButton(type: .system)
        b.setAttributedTitle(NSAttributedString(string: "Skip", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]), for: .normal)
        b.setTitleColor(UIColor(named: "Inkredible-Green"), for: .normal)
        b.layer.borderColor = UIColor(named: "Inkredible-Green")?.cgColor
        b.layer.borderWidth = 2
        b.layer.cornerRadius = 20
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let takePhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setAttributedTitle(NSAttributedString(string: "Take Photo", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]), for: .normal)
        b.setTitleColor(UIColor(named: "Inkredible-DarkText"), for: .normal)
        b.backgroundColor = UIColor(named: "Inkredible-Green")
        b.layer.cornerRadius = 20
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle


    
    init() {
      super.init(nibName: nil, bundle: nil)
      modalPresentationStyle = .pageSheet
      if let sheet = sheetPresentationController, #available(iOS 16.0, *) {
        let customDetent = UISheetPresentationController.Detent.custom { ctx in
          ctx.maximumDetentValue * 0.35
        }
        sheet.detents = [customDetent]
        sheet.prefersGrabberVisible = true
      }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
        closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        takePhotoButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }

    private func setupLayout() {
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        closeButton.delegate = self
        view.addSubview(container)
        container.addSubview(closeButton)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        container.addSubview(skipButton)
        container.addSubview(takePhotoButton)
        
        closeButton.updateSize(width: 30)

        NSLayoutConstraint.activate([
            // container
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            // close button
            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            // title
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            // description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            // skip button
            skipButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            skipButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            skipButton.heightAnchor.constraint(equalToConstant: 55),
            // takePhoto button
            takePhotoButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            takePhotoButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 55),
            // buttons equal width
            skipButton.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -12),
            takePhotoButton.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 12),
            skipButton.widthAnchor.constraint(equalTo: takePhotoButton.widthAnchor),
            // bottom padding
            takePhotoButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            skipButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func dismissSheet() {
        dismiss(animated: true)
    }

    @objc private func didTapSkip() {
        dismiss(animated: true)
    }

    @objc private func didTapTakePhoto() {
        // TODO: panggil kamera / simpan progress
        dismiss(animated: true)
    }
}

extension PhotoCaptureSheetViewController: CustomIconButtonViewDelegate {
    func didTapCustomViewButton(_ button: CustomIconButtonView) {
        dismiss(animated: true)
    }
}
