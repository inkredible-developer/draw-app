//
//  MainViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 10/06/25.
//

import UIKit
import TOCropViewController
import CropViewController

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    let anchorImageView = UIImageView()
    let tracingImageView = UIImageView()
    let captureButton = UIButton(type: .system)
    let selectTracingImageButton = UIButton(type: .system)
    let cropButton = UIButton(type: .system)
    let startARButton = UIButton(type: .system)
    
    var isSelectingTracingImage = false

    var anchorImage: UIImage? {
        didSet {
            anchorImageView.image = anchorImage
            cropButton.isEnabled = anchorImage != nil
            updateStartARButtonState()
        }
    }
    
    var tracingImage: UIImage? {
        didSet {
            tracingImageView.image = tracingImage
            updateStartARButtonState()
        }
    }
    
    private func updateStartARButtonState() {
       
        startARButton.isEnabled = anchorImage != nil && tracingImage != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
    }

    func setupUI() {
      
        anchorImageView.contentMode = .scaleAspectFit
        anchorImageView.translatesAutoresizingMaskIntoConstraints = false
        anchorImageView.backgroundColor = .systemGray6
        anchorImageView.layer.borderColor = UIColor.systemGray.cgColor
        anchorImageView.layer.borderWidth = 1
        
        tracingImageView.contentMode = .scaleAspectFit
        tracingImageView.translatesAutoresizingMaskIntoConstraints = false
        tracingImageView.backgroundColor = .systemGray6
        tracingImageView.layer.borderColor = UIColor.systemGray.cgColor
        tracingImageView.layer.borderWidth = 1

        captureButton.setTitle("Ambil Foto Anchor", for: .normal)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        selectTracingImageButton.setTitle("Pilih Gambar Tracing", for: .normal)
        selectTracingImageButton.translatesAutoresizingMaskIntoConstraints = false

        cropButton.setTitle("Crop", for: .normal)
        cropButton.isEnabled = false
        cropButton.translatesAutoresizingMaskIntoConstraints = false

        startARButton.setTitle("Mulai AR Tracing", for: .normal)
        startARButton.isEnabled = false
        startARButton.translatesAutoresizingMaskIntoConstraints = false
        
        let anchorLabel = UILabel()
        anchorLabel.text = "Gambar Anchor:"
        anchorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let tracingLabel = UILabel()
        tracingLabel.text = "Gambar Tracing:"
        tracingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let anchorStack = UIStackView(arrangedSubviews: [anchorLabel, anchorImageView, captureButton, cropButton])
        anchorStack.axis = .vertical
        anchorStack.spacing = 8
        anchorStack.translatesAutoresizingMaskIntoConstraints = false
        
        let tracingStack = UIStackView(arrangedSubviews: [tracingLabel, tracingImageView, selectTracingImageButton])
        tracingStack.axis = .vertical
        tracingStack.spacing = 8
        tracingStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [anchorStack, tracingStack, startARButton])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            anchorImageView.heightAnchor.constraint(equalToConstant: 150),
            tracingImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func setupActions() {
        captureButton.addTarget(self, action: #selector(captureAnchorPhoto), for: .touchUpInside)
        selectTracingImageButton.addTarget(self, action: #selector(selectTracingImage), for: .touchUpInside)
        cropButton.addTarget(self, action: #selector(cropAnchorPhoto), for: .touchUpInside)
        startARButton.addTarget(self, action: #selector(startARTracing), for: .touchUpInside)
    }

    @objc func captureAnchorPhoto() {
        isSelectingTracingImage = false
        presentImagePicker(sourceType: .camera)
    }
    
    @objc func selectTracingImage() {
        isSelectingTracingImage = true
        presentImagePicker(sourceType: .photoLibrary)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            let fixedImage = image.normalizedImage()
            if isSelectingTracingImage {
                self.tracingImage = fixedImage
            } else {
                self.anchorImage = fixedImage
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    @objc func cropAnchorPhoto() {
        guard let image = anchorImage else { return }
        let cropVC = CropViewController(image: image)
        cropVC.delegate = self
        present(cropVC, animated: true)
    }

    @objc func startARTracing() {
        guard let anchorImage = anchorImage, let tracingImage = tracingImage else { return }
        let arVC = ARTracingViewController()
        arVC.anchorImage = anchorImage
        arVC.tracingImage = tracingImage
        arVC.modalPresentationStyle = .fullScreen
        present(arVC, animated: true)
    }
    
    // MARK: - CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.anchorImage = image 
        cropViewController.dismiss(animated: true)
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
}

extension UIImage {
    func normalizedImage() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
