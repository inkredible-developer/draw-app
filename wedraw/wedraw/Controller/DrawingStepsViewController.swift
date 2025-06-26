

import UIKit

struct DrawingStep {
    let title: String
    let description: String
    let imageName: String
}

extension UIColor {
    convenience init(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.removeFirst()
        }

        if cString.count != 6 {
            self.init(white: 1.0, alpha: 1.0)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

class DrawingStepsViewController: UIViewController {
    
    var router : MainFlowRouter?
    private let drawID: UUID
    var drawService = DrawService()
    var drawDetails : [Draw] = []
    private var currentIndex: Int = 0
    
    init(drawID: UUID) {
        self.drawID = drawID
        print("drawID",drawID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadDraw() {
        
        drawDetails = drawService.getDrawById(draw_id: drawID)
//        print("drawDetails",drawDetails)
        currentIndex = Int(drawDetails[0].current_step - 1)
        print("currentIndex",currentIndex)
    }
    
    private var steps: [DrawingStep] = [
        DrawingStep(title: "Draw the Base Circle", description: "Start with a simple circle, this will be the skull base. Don’t worry about perfection; just aim for a clean round shape", imageName: "step1"),
        DrawingStep(title: "Draw Guide for Side", description: "Draw vertical line for direction. Use center as anchor.", imageName: "step2"),
        DrawingStep(title: "Split Face Horizontally", description: "Add eye and nose level.", imageName: "step3"),
        DrawingStep(title: "Add Chin Box", description: "Sketch box to shape the chin.", imageName: "step4"),
        DrawingStep(title: "Draw Eye Line", description: "Mark horizontal eye level.", imageName: "step5"),
        DrawingStep(title: "Mark Nose Line", description: "Place nose at 1/3 down from eyes to chin.", imageName: "step6"),
        DrawingStep(title: "Define Jaw", description: "Sketch jaw shape to connect head and chin.", imageName: "step7"),
        DrawingStep(title: "Add Ear Level", description: "Align ear from eye to nose level.", imageName: "step8"),
        DrawingStep(title: "Draw Neck Guide", description: "Extend lines for neck from jaw.", imageName: "step9"),
        DrawingStep(title: "Draw A Line to Make A Nose", description: "Add guide lines for a nose\nTip: Nose (1/3 down from eye line to chin)", imageName: "step10")
    ]

    

    // UI Components
    private let infoButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let topButton: UIButton = {
        let button = UIButton(type: .system)
             button.setTitle("Stop Drawing", for: .normal)
             button.setTitleColor(UIColor(hex: "7D7BB3"), for: .normal)
             button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17) // <-- Membuat lebih tebal
             button.isEnabled = true
             button.alpha = 1.0
             button.translatesAutoresizingMaskIntoConstraints = false
             return button
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stepDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stepImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "C6C5FC")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let buttonCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "C6C5FC")
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        button.backgroundColor = UIColor(red: 225/255, green: 252/255, blue: 185/255, alpha: 1.0) // Warna E1FCB9
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        button.backgroundColor = UIColor(red: 225/255, green: 252/255, blue: 185/255, alpha: 1.0) // Warna E1FCB9
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }()
    
    private let stepProgressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadDraw()
        view.addSubview(infoButton)
        view.addSubview(topButton)
        view.addSubview(cardView)
        view.addSubview(stepImageView)
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(buttonCardView)
        buttonCardView.addSubview(prevButton)
        buttonCardView.addSubview(nextButton)
        buttonCardView.addSubview(stepProgressLabel)

        cardView.addSubview(stepTitleLabel)
        cardView.addSubview(stepDescriptionLabel)

        setupConstraints()
        setupActions()
        updateStep()
        topButton.addTarget(self, action: #selector(topButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            topButton.centerYAnchor.constraint(equalTo: infoButton.centerYAnchor),
            topButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            cardView.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stepTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            stepTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stepTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            stepDescriptionLabel.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: 8),
            stepDescriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stepDescriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            stepDescriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            stepImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stepImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stepImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      

            bottomContainer.heightAnchor.constraint(equalToConstant: 158),
              bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonCardView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            buttonCardView.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            buttonCardView.heightAnchor.constraint(equalToConstant: 60),
            buttonCardView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 24),
            buttonCardView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -24),

            prevButton.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor),
            prevButton.leadingAnchor.constraint(equalTo: buttonCardView.leadingAnchor, constant: 16),
            prevButton.widthAnchor.constraint(equalToConstant: 48),
            prevButton.heightAnchor.constraint(equalToConstant: 48),

            nextButton.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: buttonCardView.trailingAnchor, constant: -16),
            nextButton.widthAnchor.constraint(equalToConstant: 48),
            nextButton.heightAnchor.constraint(equalToConstant: 48),

            stepProgressLabel.centerXAnchor.constraint(equalTo: buttonCardView.centerXAnchor),
            stepProgressLabel.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor)
        ])
    }

    private func setupActions() {
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(toggleInfo), for: .touchUpInside)
    }

    @objc private func toggleInfo() {
        let isHidden = cardView.isHidden
        UIView.animate(withDuration: 0.25) {
            self.cardView.alpha = isHidden ? 1 : 0
        } completion: { _ in
            self.cardView.isHidden.toggle()
        }
    }

    @objc private func prevTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            let res = drawService.updateDrawStep(draw: drawDetails[0], draw_step: Int(drawDetails[0].current_step) - 1)
            if(res == true){
                updateStep()
            }
            updateStep()
        }
    }

    @objc private func nextTapped() {
        if currentIndex < steps.count - 1 {
            currentIndex += 1
            let res = drawService.updateDrawStep(draw: drawDetails[0], draw_step:  Int(drawDetails[0].current_step) + 1)
            if(res == true){
                updateStep()
            }
        }
    }

    private func updateStep() {
        let step = steps[currentIndex]
        stepTitleLabel.text = step.title
        stepDescriptionLabel.text = step.description
        stepImageView.image = UIImage(named: step.imageName)
        stepProgressLabel.text = "Step \(currentIndex + 1) of \(steps.count)"
        topButton.setTitle(currentIndex == steps.count - 1 ? "Finish" : "Stop Drawing", for: .normal)

        prevButton.isHidden = currentIndex == 0
        nextButton.isHidden = currentIndex == steps.count - 1
    }
    @objc private func topButtonTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        // Create your destination view controller
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.interactivePopGestureRecognizer?.isEnabled = false
        homeVC.router = MainFlowRouter(navigationController: nav)

        // Set as new root
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

}
