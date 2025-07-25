//
//  ContourDetectionViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 28/06/25.
//

import UIKit
import Vision
import Accelerate

final class ContourDetectionViewController: UIViewController {
    
    var router: MainFlowRouter?
    private let referenceImage: UIImage
    private let userDrawingImage: UIImage
    private let drawId: UUID
    
    private let loadingView = LoadingPageView()
    
    init(
        referenceImage: UIImage,
        userDrawingImage: UIImage,
        drawId: UUID
    ) {
        self.referenceImage = referenceImage
        self.userDrawingImage = userDrawingImage
        self.drawId = drawId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: – UI Components
    //  private let scrollView = UIScrollView()
    //  private let contentView = UIView()
    //  
    //  private let referenceImageView: UIImageView = {
    //    let iv = UIImageView()
    //    iv.contentMode = .scaleAspectFit
    //    iv.translatesAutoresizingMaskIntoConstraints = false
    //    return iv
    //  }()
    //  private let referenceOverlay = UIView()
    //  
    //  private let userImageView: UIImageView = {
    //    let iv = UIImageView()
    //    iv.contentMode = .scaleAspectFit
    //    iv.translatesAutoresizingMaskIntoConstraints = false
    //    return iv
    //  }()
    //  private let userOverlay = UIView()
    //  
    //  private let resultLabel: UILabel = {
    //    let l = UILabel()
    //    l.font = .boldSystemFont(ofSize: 18)
    //    l.textColor = .label
    //    l.textAlignment = .center
    //    l.numberOfLines = 0
    //    l.translatesAutoresizingMaskIntoConstraints = false
    //    return l
    //  }()
    //  
    //  private let activityIndicator: UIActivityIndicatorView = {
    //    let a = UIActivityIndicatorView(style: .large)
    //    a.translatesAutoresizingMaskIntoConstraints = false
    //    return a
    //  }()
    //  
    //  // MARK: – Internal state
    //  private var referenceContours: [VNContour] = []
    //  private var userContours: [VNContour] = []
    //  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        title = "Comparing Contours"
        //    setupLayout()
        setupLoadingUI()
        startComparison()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar
        router?.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        router?.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    // MARK: – Layout
    //  private func setupLayout() {
    //    scrollView.translatesAutoresizingMaskIntoConstraints = false
    //    contentView.translatesAutoresizingMaskIntoConstraints = false
    //    view.addSubview(scrollView)
    //    scrollView.addSubview(contentView)
    //    
    //    [referenceImageView, userImageView, resultLabel, activityIndicator].forEach {
    //      contentView.addSubview($0)
    //    }
    //    // Overlays
    //    referenceOverlay.translatesAutoresizingMaskIntoConstraints = false
    //    userOverlay.translatesAutoresizingMaskIntoConstraints = false
    //    referenceImageView.addSubview(referenceOverlay)
    //    userImageView.addSubview(userOverlay)
    //    
    //    NSLayoutConstraint.activate([
    //      // scrollView full
    //      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    //      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    //      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    //      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    //      // contentView inside scrollView
    //      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
    //      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
    //      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
    //      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
    //      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    //      
    //      // referenceImageView
    //      referenceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
    //      referenceImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
    //      referenceImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    //      referenceImageView.heightAnchor.constraint(equalTo: referenceImageView.widthAnchor),
    //      // overlay full
    //      referenceOverlay.topAnchor.constraint(equalTo: referenceImageView.topAnchor),
    //      referenceOverlay.leadingAnchor.constraint(equalTo: referenceImageView.leadingAnchor),
    //      referenceOverlay.trailingAnchor.constraint(equalTo: referenceImageView.trailingAnchor),
    //      referenceOverlay.bottomAnchor.constraint(equalTo: referenceImageView.bottomAnchor),
    //      
    //      // userImageView
    //      userImageView.topAnchor.constraint(equalTo: referenceImageView.bottomAnchor, constant: 16),
    //      userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
    //      userImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    //      userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),
    //      // overlay full
    //      userOverlay.topAnchor.constraint(equalTo: userImageView.topAnchor),
    //      userOverlay.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor),
    //      userOverlay.trailingAnchor.constraint(equalTo: userImageView.trailingAnchor),
    //      userOverlay.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor),
    //      
    //      // resultLabel
    //      resultLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 24),
    //      resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
    //      resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    //      resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
    //      
    //      // activityIndicator centered
    //      activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
    //      activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    //    ])
    //    
    //    referenceImageView.image = referenceImage
    //    userImageView.image = userDrawingImage
    //  }
    
    // MARK: – Comparison Flow
    private func startComparison() {
        //      activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            let calc = ContourSimilarityCalculator()
            let similarity = calc.similarity(
                reference: self.referenceImage,
                user:      self.userDrawingImage
            )
            DispatchQueue.main.async {
                //          self.activityIndicator.stopAnimating()
                //          self.resultLabel.text = String(format: "Similarity: %.0f%%", similarity * 100)
                self.loadingView.removeFromSuperview()
                //route here
                self.router?.navigate(
                    to: .finishedDrawingViewController(
                        self.drawId,
                        Int(similarity * 100),
                        self.userDrawingImage
                    ),
                    animated: true
                )
            }
        }
    }
    
    private func setupLoadingUI() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    
    //  private func showError(_ msg: String) {
    //    DispatchQueue.main.async {
    //      self.activityIndicator.stopAnimating()
    //      self.resultLabel.text = msg
    //    }
    //  }
}

// MARK: – CGFloat helpers
fileprivate extension UIImageView {
    var boundsAspectFit: CGRect {
        guard let img = image else { return .zero }
        let scale = min(bounds.width/img.size.width,
                        bounds.height/img.size.height)
        let w = img.size.width*scale
        let h = img.size.height*scale
        let x = (bounds.width-w)/2
        let y = (bounds.height-h)/2
        return CGRect(x:x,y:y,width:w,height:h)
    }
}

fileprivate extension CGImagePropertyOrientation {
    init(_ ui: UIImage.Orientation) {
        switch ui {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

public struct ContourSimilarityCalculator {
    
    public var wCount:   Double = 0.2
    public var wArea:    Double = 0.2
    public var wChamfer: Double = 0.6
    
    public func preprocess(_ image: UIImage) -> CGImage? {
        guard let ciInput = CIImage(image: image) else { return nil }
        let context = CIContext()
        
        guard let colorControls = CIFilter(name: "CIColorControls") else { return nil }
        colorControls.setValue(ciInput, forKey: kCIInputImageKey)
        colorControls.setValue(0.0,      forKey: kCIInputSaturationKey)
        colorControls.setValue(1.5,      forKey: kCIInputContrastKey)
        
        guard let contrasted = colorControls.outputImage else { return nil }
        
        let blurred: CIImage
        if let gauss = CIFilter(name: "CIGaussianBlur") {
            gauss.setValue(contrasted, forKey: kCIInputImageKey)
            gauss.setValue(3.0,         forKey: kCIInputRadiusKey)
            blurred = gauss.outputImage ?? contrasted
        } else {
            blurred = contrasted
        }
        
        let finalCI: CIImage
        if let thresh = CIFilter(name: "CIThresholdToZero") {
            thresh.setValue(blurred, forKey: kCIInputImageKey)
            thresh.setValue(0.5,     forKey: "inputThreshold")
            finalCI = thresh.outputImage ?? blurred
        } else {
            finalCI = blurred
        }
        
        return context.createCGImage(finalCI, from: finalCI.extent)
    }
    
    public func detectContours(in cg: CGImage) throws -> VNContoursObservation {
        let request = VNDetectContoursRequest()
        request.contrastAdjustment = 1.0
        request.detectsDarkOnLight  = true
        let handler = VNImageRequestHandler(cgImage: cg, orientation: .up, options: [:])
        try handler.perform([request])
        guard let obs = request.results?.first as? VNContoursObservation else {
            throw NSError(domain: "Vision", code: -1, userInfo: [NSLocalizedDescriptionKey: "no contours"])
        }
        return obs
    }
    
    public func filter(
        _ obs: VNContoursObservation,
        margin: CGFloat = 0.02,
        minPointCount: Int = 50,
        minArea: CGFloat = 0.001
    ) -> [VNContour] {
        return (0..<obs.contourCount).compactMap { idx in
            try? obs.contour(at: idx)
        }.filter { contour in
            let bb   = contour.normalizedPath.boundingBox
            let area = bb.width * bb.height
            guard bb.minX > margin,
                  bb.minY > margin,
                  bb.maxX < (1 - margin),
                  bb.maxY < (1 - margin)
            else { return false }
            guard area > minArea else { return false }
            guard contour.normalizedPoints.count > minPointCount else { return false }
            return true
        }
    }
    
    private func areaRatio(_ a: [VNContour], _ b: [VNContour]) -> Double {
        let sumA = a.reduce(0) {
            $0 + Double($1.normalizedPath.boundingBox.width
                        * $1.normalizedPath.boundingBox.height)
        }
        let sumB = b.reduce(0) {
            $0 + Double($1.normalizedPath.boundingBox.width
                        * $1.normalizedPath.boundingBox.height)
        }
        guard sumA > 0, sumB > 0 else { return 0 }
        return min(sumA, sumB) / max(sumA, sumB)
    }
    
    private func chamferDistance(_ a: [CGPoint], _ b: [CGPoint]) -> Double {
        func sumMin(from src: [CGPoint], to dst: [CGPoint]) -> Double {
            src.reduce(0) { acc, p in
                let d2 = dst.map { q in
                    pow(Double(q.x - p.x), 2) + pow(Double(q.y - p.y), 2)
                }
                return acc + sqrt(d2.min() ?? 0)
            }
        }
        guard !a.isEmpty, !b.isEmpty else { return Double.infinity }
        let d1 = sumMin(from: a, to: b)
        let d2 = sumMin(from: b, to: a)
        return (d1 + d2) / Double(a.count + b.count)
    }
    
    private func points(of contour: VNContour) -> [CGPoint] {
        contour.normalizedPoints.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
    }
    
    public func similarityContourBased(
        reference ref: UIImage,
        user usr: UIImage
    ) -> Double {
        guard
            let refCG = preprocess(ref),
            let usrCG = preprocess(usr),
            let refObs = try? detectContours(in: refCG),
            let usrObs = try? detectContours(in: usrCG)
        else { return 0 }
        
        let rCont = filter(refObs)
        let uCont = filter(usrObs)
        guard !rCont.isEmpty, !uCont.isEmpty else { return 0 }
        
        let countRatio = Double(min(rCont.count, uCont.count))
        / Double(max(rCont.count, uCont.count))
        
        let aRatio = areaRatio(rCont, uCont)
        
        let ptsR = rCont.flatMap(points)
        let ptsU = uCont.flatMap(points)
        let chamf = chamferDistance(ptsR, ptsU)
        let chamfNorm = 1 - min(chamf / sqrt(2.0), 1.0)
        
        let score = wCount * countRatio
        + wArea  * aRatio
        + wChamfer * chamfNorm
        return score.clamped(to: 0...1)
    }
    
    public func similarityFeaturePrint(
        reference ref: UIImage,
        user usr: UIImage
    ) -> Double {
        guard let cgR = ref.cgImage, let cgU = usr.cgImage else { return 0 }
        
        func makeFP(from cg: CGImage) throws -> VNFeaturePrintObservation {
            let req = VNGenerateImageFeaturePrintRequest()
            let handler = VNImageRequestHandler(cgImage: cg, options: [:])
            try handler.perform([req])
            guard let fp = req.results?.first as? VNFeaturePrintObservation else {
                throw NSError(domain: "FP", code: -1, userInfo: nil)
            }
            return fp
        }
        
        do {
            let fpR = try makeFP(from: cgR)
            let fpU = try makeFP(from: cgU)
            var dist: Float = 0
            try fpR.computeDistance(&dist, to: fpU)
            return max(0, 1 - Double(dist))
        } catch {
            return 0
        }
    }
    
    public func similarity(
        reference ref: UIImage,
        user usr: UIImage
    ) -> Double {
        let c = similarityContourBased(reference: ref, user: usr)
        _ = similarityFeaturePrint(reference: ref, user: usr)
        
        let sim = enhancedFeaturePrintSimilarity(
            reference: ref,
            user:   usr,
            backgroundColor: .white,
            resizeTo: CGSize(width: 224, height: 224)
        )
        
        if sim <= 0.1 {
            return sim
        } else if (sim > 0.1 && sim < 0.35 ) {
            return max(c, sim)
        } else if (sim >= 0.35) {
            return boundedSum(c, sim)
        } else {
            return 0
        }
        
    }
}
public func enhancedFeaturePrintSimilarity(
    reference ref: UIImage,
    user usr: UIImage,
    backgroundColor: UIColor = .white,
    resizeTo size: CGSize = CGSize(width: 224, height: 224)
) -> Double {
    
    func flatten(_ img: UIImage) -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(img.size, true, 1.0)
        defer { UIGraphicsEndImageContext() }
        backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: img.size))
        img.draw(at: .zero)
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
    
    func resize(_ cg: CGImage) -> CGImage? {
        let ui = UIImage(cgImage: cg)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        defer { UIGraphicsEndImageContext() }
        ui.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
    
    guard
        let flatRef = flatten(ref),
        let flatUsr = flatten(usr),
        let cgRef   = resize(flatRef),
        let cgUsr   = resize(flatUsr)
    else {
        return 0
    }
    
    func makeFP(from cg: CGImage) throws -> VNFeaturePrintObservation {
        let req = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        try handler.perform([req])
        guard let fp = req.results?.first as? VNFeaturePrintObservation else {
            throw NSError(domain: "FeaturePrint", code: -1, userInfo: nil)
        }
        return fp
    }
    
    do {
        let fpR = try makeFP(from: cgRef)
        let fpU = try makeFP(from: cgUsr)
        var rawDist: Float = 0
        try fpR.computeDistance(&rawDist, to: fpU)
        // clamp di [0…1] lalu invert
        let clamped = max(0, min(rawDist, 1))
        return Double(1 - clamped)
    } catch {
        return 0
    }
}

fileprivate extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

func boundedSum(_ a: Double, _ b: Double) -> Double {
    return max(0.0, min(a + b, 1.0))
}
