//
//
//import UIKit
//import AVFoundation
//
//
//class OpacitySliderView: UIView {
//    var onOpacityChanged: ((Float) -> Void)?
//    
//    
//    let label: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor(hex: "#7D7BB3")
//        label.font = UIFont.boldSystemFont(ofSize: 14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    let slider: UISlider = {
//        let slider = UISlider()
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.minimumValue = 0.0
//        slider.maximumValue = 0.5
//        slider.value = 1.0
//        slider.setThumbImage(thumbImage(), for: .normal)
//
//
//        return slider
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//    }
//    
//
//    private func setup() {
//        backgroundColor = .white
//        layer.cornerRadius = 16
//        clipsToBounds = true
//
//        addSubview(label)
//        addSubview(slider)
//        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
//        
//        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
//            let renderer = UIGraphicsImageRenderer(size: targetSize)
//            return renderer.image { _ in
//                image.draw(in: CGRect(origin: .zero, size: targetSize))
//            }
//        }
//
//        
//        if let trackImage = UIImage(named: "gradientTrack")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch) {
//            let resizedTrack = resizeImage(image: trackImage, targetSize: CGSize(width: 200, height: 25))
//            slider.setMinimumTrackImage(resizedTrack, for: .normal)
//            slider.setMaximumTrackImage(resizedTrack, for: .normal)
//        } else {
//            print("❌ Gagal menemukan gambar gradientTrack")
//        }
//
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//
//            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
//            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
//            slider.heightAnchor.constraint(equalToConstant: 10)
//        ])
//    }
//    
//    // ✅ Fungsi ini akan memanggil closure ketika slider berubah
//    @objc private func sliderValueChanged(_ sender: UISlider) {
//        onOpacityChanged?(sender.value)
//
//        // Mengubah ukuran thumb sesuai nilai slider (semakin kecil nilainya, semakin kecil thumb)
//        let minSize: CGFloat = 10
//        let maxSize: CGFloat = 35
//        let size = minSize + CGFloat(sender.value) * (maxSize - minSize)
//        let newThumb = generateThumbImage(size: size)
//        sender.setThumbImage(newThumb, for: .normal)
//    }
//    private func generateThumbImage(size: CGFloat) -> UIImage? {
//        let thumbSize = CGSize(width: size, height: size)
//        UIGraphicsBeginImageContextWithOptions(thumbSize, false, 0.0)
//        let context = UIGraphicsGetCurrentContext()
//        let rect = CGRect(origin: .zero, size: thumbSize)
//        context?.setFillColor(UIColor(red: 225/255, green: 252/255, blue: 185/255, alpha: 1.0).cgColor)
//        context?.setStrokeColor(UIColor.black.cgColor)
//        context?.setLineWidth(1)
//        context?.fillEllipse(in: rect)
//        context?.strokeEllipse(in: rect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//
//    
//    // Lingkaran hijau custom untuk thumb
//    private static func thumbImage() -> UIImage? {
//        let size = CGSize(width: 25, height: 25)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//        let context = UIGraphicsGetCurrentContext()
//        let rect = CGRect(origin: .zero, size: size)
//        context?.setFillColor(UIColor(red: 225/255, green: 252/255, blue: 185/255, alpha: 1.0).cgColor)
//        context?.setStrokeColor(UIColor.black.cgColor)
//        context?.setLineWidth(1)
//        context?.fillEllipse(in: rect)
//        context?.strokeEllipse(in: rect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//
//    // Agar sisi kiri track transparan
//    private static func transparentImage() -> UIImage? {
//        let size = CGSize(width: 1, height: 1)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//        UIColor.clear.set()
//        UIRectFill(CGRect(origin: .zero, size: size))
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//}


//class DrawingStepsUsingCameraController: UIViewController {
//    
//    private var captureSession: AVCaptureSession?
//    private var previewLayer: AVCaptureVideoPreviewLayer?
//
//    
//    private func setupCameraBackground() {
//        captureSession = AVCaptureSession()
//        guard let captureSession = captureSession else { return }
//
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
//        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
//
//        if captureSession.canAddInput(videoInput) {
//            captureSession.addInput(videoInput)
//        }
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//        view.layer.insertSublayer(previewLayer, at: 0)
//        
//        self.previewLayer = previewLayer
//        captureSession.startRunning()
//    }
//
//
//    private var steps: [DrawingStep] = [
//        DrawingStep(title: "Draw the Base Circle", description: "Start with a simple circle, this will be the skull base. Don’t worry about perfection; just aim for a clean round shape", imageName: "step1"),
//        DrawingStep(title: "Draw Guide for Side", description: "Draw vertical line for direction. Use center as anchor.", imageName: "step2"),
//        DrawingStep(title: "Split Face Horizontally", description: "Add eye and nose level.", imageName: "step3"),
//        DrawingStep(title: "Add Chin Box", description: "Sketch box to shape the chin.", imageName: "step4"),
//        DrawingStep(title: "Draw Eye Line", description: "Mark horizontal eye level.", imageName: "step5"),
//        DrawingStep(title: "Mark Nose Line", description: "Place nose at 1/3 down from eyes to chin.", imageName: "step6"),
//        DrawingStep(title: "Define Jaw", description: "Sketch jaw shape to connect head and chin.", imageName: "step7"),
//        DrawingStep(title: "Add Ear Level", description: "Align ear from eye to nose level.", imageName: "step8"),
//        DrawingStep(title: "Draw Neck Guide", description: "Extend lines for neck from jaw.", imageName: "step9"),
//        DrawingStep(title: "Draw A Line to Make A Nose", description: "Add guide lines for a nose\nTip: Nose (1/3 down from eye line to chin)", imageName: "step10")
//    ]
//    
//
//    private var currentIndex = 0
//    private let opacitySlider = OpacitySliderView()
//
//
//    // UI Components
//    private let infoButton: UIButton = {
//        let button = UIButton(type: .infoLight)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let topButton: UIButton = {
//        let button = UIButton(type: .system)
//             button.setTitle("Stop Drawing", for: .normal)
//             button.setTitleColor(UIColor(hex: "7D7BB3"), for: .normal)
//             button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17) // <-- Membuat lebih tebal
//             button.isEnabled = true
//             button.alpha = 1.0
//             button.translatesAutoresizingMaskIntoConstraints = false
//             return button
//    }()
//    
//
//    
//    private let cardView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.darkGray
//        view.layer.cornerRadius = 16
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//
//    private let stepTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 20)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//
//    private let stepDescriptionLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//
//    private let stepImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let bottomContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let sliderContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(.white)
//        view.layer.cornerRadius = 20
//        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//
//    private let buttonCardView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
//        view.layer.cornerRadius = 24
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private let prevButton: UIButton = {
//        let button = UIButton(type: .system)
//        
//        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
//        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .black
//        
//        button.backgroundColor = UIColor(named: "Inkredible-Green") // Warna E1FCB9
//        button.layer.cornerRadius = 24
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            button.widthAnchor.constraint(equalToConstant: 60),
//            button.heightAnchor.constraint(equalToConstant: 60)
//        ])
//        
//        return button
//    }()
//    
//    
//
//    private let nextButton: UIButton = {
//        let button = UIButton(type: .system)
//        
//        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
//        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .black
//        
//        button.backgroundColor = UIColor(named: "Inkredible-Green") // Warna E1FCB9
//        button.layer.cornerRadius = 24
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            button.widthAnchor.constraint(equalToConstant: 60),
//            button.heightAnchor.constraint(equalToConstant: 60)
//        ])
//        
//        return button
//    }()
//    
//    private let stepProgressLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        previewLayer?.frame = view.bounds
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCameraBackground()
//
//        view.addSubview(infoButton)
//        view.addSubview(topButton)
//        view.addSubview(cardView)
//        view.addSubview(stepImageView)
//        view.addSubview(sliderContainer)
//        view.addSubview(bottomContainer)
//        bottomContainer.addSubview(buttonCardView)
//        buttonCardView.addSubview(prevButton)
//        buttonCardView.addSubview(nextButton)
//        buttonCardView.addSubview(stepProgressLabel)
//
//        cardView.addSubview(stepTitleLabel)
//        cardView.addSubview(stepDescriptionLabel)
//
//        setupConstraints()
//        setupActions()
//        opacitySlider.onOpacityChanged = { [weak self] value in
//            self?.stepImageView.alpha = CGFloat(value)
//        }
//        updateStep()
//    }
//
//    private func setupConstraints() {
//
//        opacitySlider.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(opacitySlider)
//        
//        
//        let containerView = UIView()
//        containerView.backgroundColor = .white
//        containerView.layer.cornerRadius = 20
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(containerView)
//
//        
//        let label = UILabel()
//        label.text = "OPACITY"
//        label.textColor = UIColor(hex: "7D7BB3")
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(label)
//    
//        
//        NSLayoutConstraint.activate([
//            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
//            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//
//            topButton.centerYAnchor.constraint(equalTo: infoButton.centerYAnchor),
//            topButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            cardView.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 20),
//            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//
//            stepTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
//            stepTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            stepTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//
//            stepDescriptionLabel.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: 8),
//            stepDescriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            stepDescriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            stepDescriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
//
//            stepImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            stepImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
//            stepImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//      
//            bottomContainer.heightAnchor.constraint(equalToConstant: 158),
//            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            sliderContainer.heightAnchor.constraint(equalToConstant: 50),
//            sliderContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            sliderContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            sliderContainer.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: -50),
//    
//            buttonCardView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
//            buttonCardView.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
//            buttonCardView.heightAnchor.constraint(equalToConstant: 60),
//            buttonCardView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 24),
//            buttonCardView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -24),
//
//            prevButton.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor),
//            prevButton.leadingAnchor.constraint(equalTo: buttonCardView.leadingAnchor, constant: 16),
//            prevButton.widthAnchor.constraint(equalToConstant: 48),
//            prevButton.heightAnchor.constraint(equalToConstant: 48),
//
//            nextButton.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor),
//            nextButton.trailingAnchor.constraint(equalTo: buttonCardView.trailingAnchor, constant: -16),
//            nextButton.widthAnchor.constraint(equalToConstant: 48),
//            nextButton.heightAnchor.constraint(equalToConstant: 48),
//            
//            label.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor, constant: 50),
//            label.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor, constant: 5),
//            
//            opacitySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 140),
//            opacitySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            opacitySlider.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: -50),
//            opacitySlider.heightAnchor.constraint(equalToConstant: 45),
//
//            stepProgressLabel.centerXAnchor.constraint(equalTo: buttonCardView.centerXAnchor),
//            stepProgressLabel.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor)
//        ])
//        
//    }
//
//    private func setupActions() {
//        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
//        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
//        infoButton.addTarget(self, action: #selector(toggleInfo), for: .touchUpInside)
//    }
//
//    @objc private func toggleInfo() {
//        let isHidden = cardView.isHidden
//        UIView.animate(withDuration: 0.25) {
//            self.cardView.alpha = isHidden ? 1 : 0
//        } completion: { _ in
//            self.cardView.isHidden.toggle()
//        }
//    }
//
//    @objc private func prevTapped() {
//        if currentIndex > 0 {
//            currentIndex -= 1
//            updateStep()
//        }
//    }
//
//    @objc private func nextTapped() {
//        if currentIndex < steps.count - 1 {
//            currentIndex += 1
//            updateStep()
//        }
//    }
//
//    private func updateStep() {
//        let step = steps[currentIndex]
//        stepTitleLabel.text = step.title
//        stepDescriptionLabel.text = step.description
//        stepImageView.image = UIImage(named: step.imageName)
//        stepProgressLabel.text = "Step \(currentIndex + 1) of \(steps.count)"
//        topButton.setTitle(currentIndex == steps.count - 1 ? "Finish" : "Stop Drawing", for: .normal)
//
//        prevButton.isHidden = currentIndex == 0
//        nextButton.isHidden = currentIndex == steps.count - 1
//    }
//}
