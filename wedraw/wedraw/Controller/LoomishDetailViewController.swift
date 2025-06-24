//
//  LoomishDetailViewController.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//


import UIKit

class LoomishDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        view.layer.cornerRadius = 20
        view.clipsToBounds = true

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "The Loomis Method:\nBuilding Head Structures"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Close Button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .red
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        
//        // Circle Background View
//        let circleView = UIView()
//        circleView.translatesAutoresizingMaskIntoConstraints = false
//        circleView.backgroundColor = .white
//        circleView.layer.cornerRadius = 50 // Will be set to half of width/height later
//        circleView.clipsToBounds = true
        
        // Image (Placeholder)
        let imageView = UIImageView(image: UIImage(named: "LoomishDetail") ?? UIImage(systemName: "person.crop.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray

        // Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.text = """
        The Loomis Method, developed by illustrator **Andrew Loomis**, is a timeless drawing technique that helps artists understand and build the human head from any angle.

        It starts with a basic circle and uses simple guiding lines to map out facial proportions like draw a vertical and horizontal line, making it easier to draw faces that look natural and consistent.

        We use Loomis method because it breaks down a complex subject (the head) into simple, repeatable steps you can follow and master.
        """
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        
        view.addSubview(imageView)
//        circleView.addSubview(imageView)
//        view.addSubview(imageView)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            
//            circleView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            circleView.widthAnchor.constraint(equalToConstant: 100),
//            circleView.heightAnchor.constraint(equalToConstant: 100),

            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 120),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}
