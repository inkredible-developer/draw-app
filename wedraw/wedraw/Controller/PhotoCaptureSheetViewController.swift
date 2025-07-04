//
//  PhotoCaptureSheetViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 26/06/25.
//


import UIKit

class TaggedImagePickerController: UIImagePickerController {
    var pickerTag: Int = 0
}

class PhotoCaptureSheetViewController: UIViewController {
    
    var router: MainFlowRouter?
    var tracingImage: UIImage
    var drawId: UUID
    var isFinished: Bool
    
    // MARK: - UI Elements
    
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
        l.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
    
    private let skipButton: UIButton = {
        let b = UIButton(type: .system)
        b.setAttributedTitle(NSAttributedString(string: "Skip", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)]), for: .normal)
        b.setTitleColor(UIColor(named: "Inkredible-Green"), for: .normal)
        b.layer.borderColor = UIColor(named: "Inkredible-Green")?.cgColor
        b.layer.borderWidth = 2
        b.layer.cornerRadius = 20
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let takePhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setAttributedTitle(NSAttributedString(string: "Take Photo", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)]), for: .normal)
        b.setTitleColor(UIColor(named: "Inkredible-DarkText"), for: .normal)
        b.backgroundColor = UIColor(named: "Inkredible-Green")
        b.layer.cornerRadius = 20
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Lifecycle
    
    
    
    init(tracingImage: UIImage, drawId: UUID, isFinished: Bool) {
        self.tracingImage = tracingImage
        self.drawId = drawId
        self.isFinished = isFinished
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
        updateUITexts()
        closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        takePhotoButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    private func updateUITexts() {
        if isFinished {
            titleLabel.text = "Snap a Photo of Your Final Drawing!"
            descriptionLabel.text = "Your photo will be saved to showcase your completed masterpiece"
            skipButton.setAttributedTitle(NSAttributedString(string: "Skip", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)]), for: .normal)
            
            takePhotoButton.setAttributedTitle(NSAttributedString(string: "Take Photo", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)]), for: .normal)
            
        } else {
            titleLabel.text = "Save Your Drawing Progress?"
            descriptionLabel.text = "It looks like you haven’t completed all the steps. Still want to save your progress for later?"
            skipButton.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)]), for: .normal)
            takePhotoButton.setAttributedTitle(NSAttributedString(string: "Save", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)]), for: .normal)
        }
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor(named: "Inkredible-DarkText")
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
        if(isFinished){
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                if let router = self.router {
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
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func didTapTakePhoto() {
        if(isFinished){
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                // buat dan simpan coordinator di SceneDelegate
                if let sceneDelegate = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.delegate as? SceneDelegate,
                   let root = sceneDelegate.window?.rootViewController?.topmostPresentedViewController
                {
                    sceneDelegate.photoCaptureCoordinator = PhotoCaptureCoordinator(
                        presentingViewController: root,
                        router: self.router,
                        tracingImage: self.tracingImage,
                        drawId: self.drawId
                    )
                    sceneDelegate.photoCaptureCoordinator?.startCamera()
                }
            }
        } else {
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                if let router = self.router {
                    
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
        
    }
}

extension PhotoCaptureSheetViewController: CustomIconButtonViewDelegate {
    func didTapCustomViewButton(_ button: CustomIconButtonView) {
        dismiss(animated: true)
    }
}

class PhotoCaptureCoordinator: NSObject,
                               UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private weak var presentingViewController: UIViewController?
    private let router: MainFlowRouter?
    private let tracingImage: UIImage
    private let drawId: UUID
    
    init(presentingViewController: UIViewController,
         router: MainFlowRouter?,
         tracingImage: UIImage,
         drawId: UUID
    )
    {
        self.presentingViewController = presentingViewController
        self.router = router
        self.tracingImage = tracingImage
        self.drawId = drawId
        super.init()
    }
    
    func startCamera() {
        let picker = TaggedImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.pickerTag = 100
        
        let overlay = UIView(frame: picker.view.frame)
        let iv = UIImageView(image: tracingImage)
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.3
        iv.frame = overlay.bounds
        overlay.addSubview(iv)
        
        let maxY = picker.view.bounds.height - 140
        overlay.frame = CGRect(x: 0, y: 0,
                               width: picker.view.bounds.width,
                               height: maxY)
        picker.cameraOverlayView = overlay
        
        picker.showsCameraControls = true
        presentingViewController?.present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let tagged = picker as? TaggedImagePickerController,
              tagged.pickerTag == 100,
              let userPhoto = info[.originalImage] as? UIImage
        else { return }
        
        router?.navigate(
            to: .contourDetectionViewController(
                tracingImage,
                userPhoto,
                drawId
            ),
            animated: true
        )
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

