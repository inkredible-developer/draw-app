//
//  AngleSelectionViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit

class AngleSelectionViewController: UIViewController {

    // MARK: - Properties (view)

    private let mainImageView = UIImageView()
    private let angleLabel = UILabel()
    private let presetAngleButton = UIButton()
    private let chooseButton = UIButton()
    private let bottomContainerView = UIView()
    private let infoToastView = UIView()
    private let infoToastLabel = UILabel()
    private let toastOverlayView = UIView()
    private let infoButton = UIButton(type: .system)

    // MARK: - Properties (data)
    private var isToastVisible = false
    private var dismissWorkItem: DispatchWorkItem?

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Your Angle"
        view.backgroundColor = .white

        setupNavigationBar()
        setupInfoButton()
        setupMainImageView()
        setupAngleLabel()
        setupBottomContainer()
        setupPresetAngleButton()
        setupChooseButton()
        setupAngleSelectionButtons()
        setupInfoToast()
        setupToastOverlay()
    }

    // MARK: - Setup Views

    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
    }

    private func setupInfoButton() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        infoButton.setImage(UIImage(systemName: "info.circle.fill", withConfiguration: symbolConfig), for: .normal)
        infoButton.tintColor = UIColor(red: 0.75, green: 0.75, blue: 0.9, alpha: 1.0)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

        view.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupMainImageView() {
        mainImageView.image = UIImage(systemName: "person.crop.artframe") // Placeholder
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.tintColor = .lightGray
        
        view.addSubview(mainImageView)
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor)
        ])
    }

    private func setupAngleLabel() {
        angleLabel.text = "3/4 Angle"
        angleLabel.textColor = .black
        angleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        view.addSubview(angleLabel)
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            angleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 20),
            angleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBottomContainer() {
        bottomContainerView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0) // Lighter purple
        
        view.addSubview(bottomContainerView)
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 157)
        ])
    }
    
    private func setupPresetAngleButton() {
        presetAngleButton.setTitle("Preset Angle", for: .normal)
        presetAngleButton.setTitleColor(UIColor(.black), for: .normal)
        presetAngleButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        presetAngleButton.backgroundColor = .clear
        
        bottomContainerView.addSubview(presetAngleButton)
        presetAngleButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupChooseButton() {
        chooseButton.setTitle("Choose", for: .normal)
        chooseButton.setTitleColor(.black, for: .normal)
        chooseButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        chooseButton.backgroundColor = UIColor(named: "green_light")
        chooseButton.layer.cornerRadius = 16
        
        bottomContainerView.addSubview(chooseButton)
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chooseButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 44),
            chooseButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -55),
            chooseButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 32),
            chooseButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -32),
            
            // Constrain "Preset Angle" button relative to "Choose" button
            presetAngleButton.bottomAnchor.constraint(equalTo: chooseButton.topAnchor, constant: -15),
            presetAngleButton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor)
        ])
    }

    private func setupAngleSelectionButtons() {
        let radius: CGFloat = 150
        let buttonSize: CGFloat = 50
        // Adjust angles for a better curve on screen
        let angles: [CGFloat] = [1.1, 1.35, 1.5707, 1.8, 2.05] // Angles in radians, for bottom arc
        let buttonIcons = ["preset_top", "preset_side_left", "preset_quarter", "preset_side_right", "preset_bottom"]

        let circularBackground = UIView()
        circularBackground.backgroundColor = .systemGray5
        // Make it a half-circle on top
        circularBackground.layer.cornerRadius = 150
        circularBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]


        view.insertSubview(circularBackground, belowSubview: bottomContainerView)
        circularBackground.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, angle) in angles.enumerated() {
            let button = UIButton()
            let image = UIImage(named: buttonIcons[index])
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            
            if index == 2 {
                button.backgroundColor = .black
                button.layer.borderColor = UIColor.white.cgColor
                button.layer.borderWidth = 2
            } else {
                button.backgroundColor = .systemGray3
            }
            button.layer.cornerRadius = buttonSize / 2
            
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            let centerXConstant = radius * cos(angle)
            let centerYConstant = radius * sin(angle) - radius - 20 // Adjust to be above the bottom container
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: centerXConstant),
                button.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: centerYConstant),
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
        }
        
        NSLayoutConstraint.activate([
            circularBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            circularBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            circularBackground.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: -20),
            circularBackground.topAnchor.constraint(equalTo: angleLabel.bottomAnchor, constant: 20)
        ])
    }

    private func setupInfoToast() {
        infoToastView.backgroundColor = UIColor(white: 0.2, alpha: 0.95)
        infoToastView.layer.cornerRadius = 12
        infoToastView.alpha = 0 // Initially hidden
        view.addSubview(infoToastView)
        infoToastView.translatesAutoresizingMaskIntoConstraints = false

        infoToastLabel.text = "Use your finger to rotate the model and choose the angle that best suits your needs."
        infoToastLabel.textColor = .white
        infoToastLabel.textAlignment = .center
        infoToastLabel.numberOfLines = 0
        infoToastLabel.font = .systemFont(ofSize: 16)
        infoToastView.addSubview(infoToastLabel)
        infoToastLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            infoToastView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            infoToastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoToastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoToastLabel.topAnchor.constraint(equalTo: infoToastView.topAnchor, constant: 16),
            infoToastLabel.bottomAnchor.constraint(equalTo: infoToastView.bottomAnchor, constant: -16),
            infoToastLabel.leadingAnchor.constraint(equalTo: infoToastView.leadingAnchor, constant: 16),
            infoToastLabel.trailingAnchor.constraint(equalTo: infoToastView.trailingAnchor, constant: -16)
        ])
    }

    private func setupToastOverlay() {
        toastOverlayView.backgroundColor = .clear
        toastOverlayView.alpha = 0
        view.addSubview(toastOverlayView)
        toastOverlayView.translatesAutoresizingMaskIntoConstraints = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissToast))
        toastOverlayView.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            toastOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            toastOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toastOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toastOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Button Helpers

    @objc private func infoButtonTapped() {
        if isToastVisible { return }
        
        isToastVisible = true
        view.bringSubviewToFront(toastOverlayView)
        view.bringSubviewToFront(infoToastView)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.infoToastView.alpha = 1.0
            self.toastOverlayView.alpha = 1.0
        }, completion: nil)
        
        dismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissToast()
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }

    @objc private func dismissToast() {
        if !isToastVisible { return }
        
        dismissWorkItem?.cancel()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.infoToastView.alpha = 0.0
            self.toastOverlayView.alpha = 0.0
        }, completion: { _ in
            self.isToastVisible = false
        })
    }

}
