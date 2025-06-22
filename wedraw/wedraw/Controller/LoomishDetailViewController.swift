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
        view.backgroundColor = .white

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Loomis Method"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Circle view
        let circleView = UIView()
        circleView.backgroundColor = .lightGray
        circleView.layer.cornerRadius = 75
        circleView.translatesAutoresizingMaskIntoConstraints = false

        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = """
        The Loomis Method, developed by illustrator Andrew Loomis, is a timeless drawing technique that helps artists understand and build the human head from any angle.

        It starts with a basic sphere and uses simple guiding lines to map out facial proportions, making it easier to draw faces that look natural and consistent.

        We use Loomis Method because it breaks down a complex subject (the head) into simple, repeatable steps you can follow and master.
        """
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(circleView)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
            circleView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 150),
            circleView.heightAnchor.constraint(equalToConstant: 150),
                                
            descriptionLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}
