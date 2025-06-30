//
//  LoomishDetailViewController.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

//class TaggedImagePickerController: UIImagePickerController {
//    var pickerTag: Int = 0
//}

class LoomishDetailViewController: UIViewController {
    
    
    var router: MainFlowRouter?
    
    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "Inkredible-DarkText")
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let closeButton = CustomIconButtonView(iconName: "xmark", iconColor: UIColor(named: "Inkredible-Red") ?? .systemRed, backgroundColor: UIColor(named: "Inkredible-Green") ?? .green, iconScale: 0.5)
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Snap of Photo To See How You Are Improving!"
        l.textColor = .white
        //        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "LoomishDetail") ?? UIImage(systemName: "person.crop.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "Your photo will be saved and you can see your progress on the main screen"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .regular)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    
    
    // MARK: - Lifecycle
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController, #available(iOS 16.0, *) {
            let customDetent = UISheetPresentationController.Detent.custom { ctx in
                ctx.maximumDetentValue * 0.75
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
        updateUITexts()
        closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
    }
    
    private func updateUITexts() {
        let text = """
        The Loomis Method, developed by illustrator Andrew Loomis, is a timeless drawing technique that helps artists understand and build the human head from any angle.
        
        It starts with a basic circle and uses simple guiding lines to map out facial proportions like draw a vertical and horizontal line, making it easier to draw faces that look natural and consistent.
        
        We use Loomis method because it breaks down a complex subject (the head) into simple, repeatable steps you can follow and master.
        """
        
        let attributedText = NSMutableAttributedString(string: text,
                                                       attributes: [
                                                        //                .font: UIFont.systemFont(ofSize: 15),
                                                        .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .regular),
                                                        .foregroundColor: UIColor.white
                                                       ]
        )
        
        // Cari kata "Andrew Loomis"
        if let range = text.range(of: "Andrew Loomis") {
            let nsRange = NSRange(range, in: text)
            attributedText.addAttributes([
                //                .font: UIFont.boldSystemFont(ofSize: 15)
                .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .bold)
            ], range: nsRange)
        }
        
        titleLabel.text = "The Loomis Method:\nBuilding Head Structures"
        descriptionLabel.attributedText = attributedText
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor(named: "Inkredible-DarkText")
        closeButton.delegate = self
        view.addSubview(container)
        container.addSubview(closeButton)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        container.addSubview(imageView)
        
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
            // image
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            // description
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
        ])
    }
    
    // MARK: - Actions
    
    @objc private func dismissSheet() {
        dismiss(animated: true)
    }
    
}

extension LoomishDetailViewController: CustomIconButtonViewDelegate {
    func didTapCustomViewButton(_ button: CustomIconButtonView) {
        dismiss(animated: true)
    }
}




//import UIKit
//
//class LoomishDetailViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//
//    private func setupUI() {
//        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
//        view.layer.cornerRadius = 20
//        view.clipsToBounds = true
//
//        // Title Label
//        let titleLabel = UILabel()
//        titleLabel.text = "The Loomis Method:\nBuilding Head Structures"
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
//        titleLabel.textAlignment = .center
//        titleLabel.textColor = UIColor.white
//        titleLabel.numberOfLines = 2
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        // Close Button
//        let closeButton = UIButton(type: .system)
//        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//        closeButton.tintColor = .red
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
//
//
//        // Image (Placeholder)
//        let imageView = UIImageView(image: UIImage(named: "LoomishDetail") ?? UIImage(systemName: "person.crop.circle"))
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.tintColor = .gray
//
//        // Description Label
//        let descriptionLabel = UILabel()
//        descriptionLabel.numberOfLines = 0
//        descriptionLabel.textAlignment = .left
//        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
//        descriptionLabel.textColor = UIColor.white
//        descriptionLabel.text = """
//        The Loomis Method, developed by illustrator **Andrew Loomis**, is a timeless drawing technique that helps artists understand and build the human head from any angle.
//
//        It starts with a basic circle and uses simple guiding lines to map out facial proportions like draw a vertical and horizontal line, making it easier to draw faces that look natural and consistent.
//
//        We use Loomis method because it breaks down a complex subject (the head) into simple, repeatable steps you can follow and master.
//        """
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(titleLabel)
//        view.addSubview(closeButton)
//
//        view.addSubview(imageView)
////        circleView.addSubview(imageView)
////        view.addSubview(imageView)
//        view.addSubview(descriptionLabel)
//
//        NSLayoutConstraint.activate([
//            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
//            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            closeButton.widthAnchor.constraint(equalToConstant: 30),
//            closeButton.heightAnchor.constraint(equalToConstant: 30),
//
//            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//
//
////            circleView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
////            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
////            circleView.widthAnchor.constraint(equalToConstant: 100),
////            circleView.heightAnchor.constraint(equalToConstant: 100),
//
//            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            imageView.widthAnchor.constraint(equalToConstant: 250),
//            imageView.heightAnchor.constraint(equalToConstant: 120),
//
//            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
//            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
//        ])
//    }
//
//    @objc private func closeTapped() {
//        dismiss(animated: true, completion: nil)
//    }
//}
