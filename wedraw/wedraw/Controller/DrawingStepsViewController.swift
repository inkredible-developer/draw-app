import UIKit



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
    var stepService = StepService()
    var drawDetails : [Draw] = []
    var dataSteps : [Step] = []
    private var currentIndex: Int = 0
//    var steps: [DrawingStep] = []
    
    private var tracingImage = UIImage(named: "traceng")
    
    private var tooltip: TooltipView?
    
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
        currentIndex = Int(drawDetails[0].current_step - 1)
        print("currentIndex",currentIndex)
        
        dataSteps = stepService.getSteps(angle_id: drawDetails[0].angle_id)
        steps = [
            DrawingStep(
                title: "Draw the Base Circle",
                description: "Start with a simple circle, this will be the skull base. Don’t worry about perfection; just aim for a clean round shape",
                imageName: dataSteps[0].image!
            ),
            DrawingStep(
                title: "Draw Guide for Side",
                description: "Draw vertical line for direction. Use center as anchor.",
                imageName: dataSteps[1].image!
            ),
            DrawingStep(
                title: "Split Face Horizontally",
                description: "Add eye and nose level.",
                imageName: dataSteps[2].image!
            ),
            DrawingStep(
                title: "Add Chin Box",
                description: "Sketch box to shape the chin.",
                imageName: dataSteps[3].image!
            ),
            DrawingStep(
                title: "Draw Eye Line",
                description: "Mark horizontal eye level.",
                imageName: dataSteps[4].image!
            ),
            DrawingStep(
                title: "Mark Nose Line",
                description: "Place nose at 1/3 down from eyes to chin.",
                imageName: dataSteps[5].image!
            ),
            DrawingStep(
                title: "Define Jaw",
                description: "Sketch jaw shape to connect head and chin.",
                imageName: dataSteps[6].image!
            ),
            DrawingStep(
                title: "Add Ear Level",
                description: "Align ear from eye to nose level.",
                imageName: dataSteps[7].image!
            ),
            DrawingStep(
                title: "Draw Neck Guide",
                description: "Extend lines for neck from jaw.",
                imageName: dataSteps[8].image!
            ),
            DrawingStep(
                title: "Draw A Line to Make A Nose",
                description: "Add guide lines for a nose\nTip: Nose (1/3 down from eye line to chin)",
                imageName: dataSteps[9].image!
            )
        ]
        print("steps",steps)
    }
//    func loadDraw() {
//        drawDetails = drawService.getDrawById(draw_id: drawID)
//        currentIndex = Int(drawDetails[0].current_step - 1)
//        print("currentIndex",currentIndex)
//    }
    
    private var steps: [DrawingStep] = [
        DrawingStep(title: "Draw the Base Circle", description: "Start with a simple circle, this will be the skull base. Don't worry about perfection; just aim for a clean round shape", imageName: "step1"),
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
    private let infoButton = CustomIconButtonView(
        iconName: "info",
        iconColor: .white,
        backgroundColor: UIColor(named: "Inkredible-DarkPurple") ?? .systemYellow,
        iconScale: 0.5
    )
    
//    private let topButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Stop Drawing", for: .normal)
//        button.setTitleColor(UIColor(hex: "7D7BB3"), for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//        button.isEnabled = true
//        button.alpha = 1.0
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor(named: "Inkredible-Green"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        return button
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
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let buttonCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let prevButton: UIButton = {
        let button = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "Inkredible-DarkText")

        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 55),
            button.heightAnchor.constraint(equalToConstant: 55)
        ])

        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "Inkredible-DarkText")

        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 55),
            button.heightAnchor.constraint(equalToConstant: 55)
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
        setupNavBarColor()
        configureNavigationBar()
        setupUI()
        setupActions()
        updateStep()
        
        // Show tooltip when view appears
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showTooltip(withText: self.steps[self.currentIndex].description)
        }
    }
    
    private func setupNavBarColor() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "Inkredible-DarkPurple") ?? .black]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.tintColor = UIColor(named: "Inkredible-Green") ?? .green
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = UIColor(named: "Inkredible-Green") ?? .green
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "Inkredible-DarkPurple") ?? .black]
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Drawing With Reference"
        navigationItem.hidesBackButton = true
        
        finishButton.setTitle(currentIndex == steps.count - 1 ? "Finish" : "Save", for: .normal)
        
        let saveItem = UIBarButtonItem(
            customView: finishButton
        )
        
        lazy var infoItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoItem
        
        navigationItem.rightBarButtonItem = saveItem
    }
    
    private func setupUI() {
        infoButton.updateSize(width: 30)
        infoButton.delegate = self
        
        view.addSubview(infoButton)
//        view.addSubview(topButton)
        view.addSubview(stepImageView)
        view.addSubview(bottomContainer)
        
        bottomContainer.addSubview(buttonCardView)
        buttonCardView.addSubview(prevButton)
        buttonCardView.addSubview(nextButton)
        buttonCardView.addSubview(stepProgressLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//
//            topButton.centerYAnchor.constraint(equalTo: infoButton.centerYAnchor),
//            topButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stepImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stepImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stepImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
            bottomContainer.heightAnchor.constraint(equalToConstant: 158),
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonCardView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            buttonCardView.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            buttonCardView.heightAnchor.constraint(equalToConstant: 55),
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
//        topButton.addTarget(self, action: #selector(topButtonTapped), for: .touchUpInside)
    }
    
    @objc private func finishButtonTapped() {
        if currentIndex == steps.count - 1 {
            // This is the last step - go to DrawingStepsUsingCameraController
//            let nextVC = DrawingStepsUsingCameraController()
            let nextVC = CameraTesterViewController()
            if let router = router {
                router.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                navigationController?.pushViewController(nextVC, animated: true)
            }
        } else {
            if let router = router {
                router.navigateToRoot(animated: true)
            } else {
                // Manual navigation to home
                let homeVC = HomeViewController()
                let nav = UINavigationController(rootViewController: homeVC)
                homeVC.router = MainFlowRouter(navigationController: nav)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                }
            }
        }
    }

    @objc private func toggleInfo() {
        toggleTooltip()
    }

    @objc private func prevTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            let res = drawService.updateDrawStep(draw: drawDetails[0], draw_step: Int(drawDetails[0].current_step) - 1)
            if(res == true){
                updateStep()
                showTooltip(withText: steps[currentIndex].description)
            }
        }
    }

    @objc private func nextTapped() {
        if currentIndex < steps.count - 1 {
            currentIndex += 1
            let res = drawService.updateDrawStep(draw: drawDetails[0], draw_step: Int(drawDetails[0].current_step) + 1)
            if(res == true){
                updateStep()
                showTooltip(withText: steps[currentIndex].description)
            }
        } else {
            showCompletionTooltip()
        }
    }

    private func updateStep() {
        let step = steps[currentIndex]
        stepTitleLabel.text = step.title
        stepDescriptionLabel.text = step.description
//        if let data = try? Data(contentsOf: ),
//           let image = UIImage(data: data) {
//            let imageView = UIImageView(image: image)
            
//        let fileName = "SceneSnapshot_1751126135.901451.png"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(step.imageName)

        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            
            stepImageView.image = image
        }
            
//        stepImageView.image = UIImage(named: step.imageName)
        stepProgressLabel.text = "Step \(currentIndex + 1) of \(steps.count)"
        
        // Update navigation
        let isLast = (currentIndex == steps.count - 1)
        finishButton.setTitle(isLast ? "Finish" : "Save", for: .normal)
//        topButton.setTitle(isLast ? "Finish" : "Stop Drawing", for: .normal)
        
        prevButton.isHidden = currentIndex == 0
        nextButton.isHidden = currentIndex == steps.count - 1
    }
    
    private func showCompletionTooltip() {
        let tooltipView = TooltipView(text: "Great job! You've completed all the steps!") { [weak self] in
            self?.dismiss(animated: true)
        }

        view.addSubview(tooltipView)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tooltipView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tooltipView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tooltipView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    @objc private func toggleTooltip() {
        if let tip = tooltip {
            // Hide & remove if already showing
            UIView.animate(withDuration: 0.2, animations: {
                tip.alpha = 0
            }, completion: { _ in
                tip.removeFromSuperview()
                self.tooltip = nil
            })
        } else {
            // Create & show if not showing
            let text = steps[currentIndex].description
            let tip = TooltipView(text: text)
            tip.alpha = 0
            tip.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tip)
            self.tooltip = tip

            NSLayoutConstraint.activate([
                tip.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 12),
                tip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ])

            UIView.animate(withDuration: 0.2) {
                tip.alpha = 1
            }
        }
    }
    
    private func showTooltip(withText text: String, autoDismiss: Bool = true) {
        tooltip?.removeFromSuperview()
        
        let tip = TooltipView(text: text) { [weak self] in
            self?.tooltip = nil
        }
        
        tip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tip)
        tooltip = tip
        
        NSLayoutConstraint.activate([
            tip.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 20),
            tip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tip.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        view.layoutIfNeeded()
    
        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak tip] in
                guard let tip = tip, tip == self?.tooltip else { return }
                
                UIView.animate(withDuration: 0.5, animations: {
                    tip.alpha = 0
                }, completion: { _ in
                    if tip == self?.tooltip {
                        tip.removeFromSuperview()
                        self?.tooltip = nil
                    }
                })
            }
        }
    }
    
//    @objc private func topButtonTapped() {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first else {
//            return
//        }
//
//        // Create your destination view controller
//        let homeVC = HomeViewController()
//        let nav = UINavigationController(rootViewController: homeVC)
//        nav.interactivePopGestureRecognizer?.isEnabled = false
//        homeVC.router = MainFlowRouter(navigationController: nav)
//
//        // Set as new root
//        window.rootViewController = nav
//        window.makeKeyAndVisible()
//    }
}

// MARK: - CustomIconButtonViewDelegate
extension DrawingStepsViewController: CustomIconButtonViewDelegate {
    func didTapCustomViewButton(_ button: CustomIconButtonView) {
        if button === infoButton {
            toggleTooltip()
        }
    }
}
