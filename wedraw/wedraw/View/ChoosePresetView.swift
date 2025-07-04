import UIKit
import AVFoundation

protocol ChoosePresetPickerViewDelegate: AnyObject {
    func choosePresetPickerView(_ picker: ChoosePresetPickerView, didSelectPresetAt index: Int)
}

class ChoosePresetPickerView: UIView {
    weak var delegate: ChoosePresetPickerViewDelegate?
    
    private var presetViews: [UIImageView] = []
    private let presetCount = 5
    private var currentIndex: Int?
    private var selectedPresetIndex: Int = 0
    private var isCircularMode = false
    private var hasUserInteracted = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupPresets()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        setupPresets()
        setupGesture()
    }

    private func setupPresets() {
        let presetIcons = ["preset_front", "preset_side_right", "preset_quarter", "preset_side_left", "preset_top"]
        for i in 0..<presetCount {
            let presetView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            presetView.layer.cornerRadius = 25
            presetView.backgroundColor = UIColor(named: "Inkredible-onBoarding-Back")
            presetView.contentMode = .scaleAspectFit
            presetView.image = UIImage(named: presetIcons[i])
            presetView.layer.borderWidth = 2
            presetView.layer.borderColor = UIColor.clear.cgColor
            presetView.isUserInteractionEnabled = false
            
            // Set initial opacity - front view (index 0) is default selected
            if i == 0 {
                presetView.alpha = 1.0 // High opacity for default selected
            } else {
                presetView.alpha = 0.4 // Lower opacity for others
            }
            
            addSubview(presetView)
            presetViews.append(presetView)
        }
        layoutPresetsHorizontally()
    }
    
    private func layoutPresetsHorizontally() {
        let spacing: CGFloat = 70
        let centerX = bounds.midX
        let y = bounds.midY
        
        for (index, preset) in presetViews.enumerated() {
            let x = centerX + CGFloat(index) * spacing
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                preset.center = CGPoint(x: x, y: y)
                preset.frame.size = CGSize(width: 35, height: 35)
                preset.layer.cornerRadius = 17.5
            }, completion: nil)
        }
    }
    
    private func layoutPresetsCircular() {
        guard let superview = superview else { return }
//        let bottomContainerTopY = frame.maxY
//        if let setAngleView = superview as? UIView, let bottomContainer = setAngleView.subviews.first(where: { $0.accessibilityIdentifier == "bottomContainerView" }) {
        if let bottomContainer = superview.subviews.first(where: { $0.accessibilityIdentifier == "bottomContainerView" }) {

            // If bottomContainerView is accessible, use its frame
            let converted = bottomContainer.convert(bottomContainer.bounds, to: self)
            // Use the y of the top edge
            let y = converted.minY
            // Calculate radius so the arc's bottom is at y
            let center = CGPoint(x: bounds.midX, y: y)
            let radius = y
            let backgroundSize: CGFloat = radius * 2
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath()
            path.addArc(withCenter: CGPoint(x: radius, y: backgroundSize),
                       radius: radius,
                       startAngle: CGFloat.pi,
                       endAngle: 0,
                       clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: backgroundSize))
            path.close()
            maskLayer.path = path.cgPath
            for (index, preset) in presetViews.enumerated() {
                let angle = CGFloat.pi + (CGFloat(index) / CGFloat(presetCount - 1) * CGFloat.pi)
                let x = center.x + cos(angle) * radius * 0.8 // Slightly inside the arc
                let yIcon = y + sin(angle) * radius * 0.8 - radius
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    preset.center = CGPoint(x: x, y: yIcon)
                    preset.frame.size = CGSize(width: 50, height: 50)
                    preset.layer.cornerRadius = 25
                }, completion: nil)
            }
            return
        }
        let radius: CGFloat = 180
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let backgroundSize: CGFloat = radius * 2
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: radius, y: radius),
                   radius: radius,
                   startAngle: CGFloat.pi,
                   endAngle: 0,
                   clockwise: true)
        path.addLine(to: CGPoint(x: radius, y: radius))
        path.close()
        maskLayer.path = path.cgPath
        for (index, preset) in presetViews.enumerated() {
            let angle = CGFloat.pi + (CGFloat(index) / CGFloat(presetCount - 1) * CGFloat.pi)
            let x = center.x + cos(angle) * radius * 0.8
            let y = center.y + sin(angle) * radius * 0.8
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                preset.center = CGPoint(x: x, y: y)
                preset.frame.size = CGSize(width: 50, height: 50)
                preset.layer.cornerRadius = 25
            }, completion: nil)
        }
    }

    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if !isCircularMode {
            showDragHintAnimation()
        }
    }
    
    private func showDragHintAnimation() {
        for (index, preset) in presetViews.enumerated() {
            UIView.animate(withDuration: 0.1, delay: Double(index) * 0.05, options: [.curveEaseInOut], animations: {
                preset.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                    preset.transform = CGAffineTransform.identity
                }) { _ in
                    if index == self.presetViews.count - 1 {
                        self.hapticFeedback.impactOccurred()
                    }
                }
            }
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        if !hasUserInteracted {
            hasUserInteracted = true
            isCircularMode = true
            layoutPresetsCircular()
        }
        if isCircularMode {
            let deltaX = location.x - center.x
            let deltaY = location.y - center.y
            let angle = atan2(deltaY, deltaX)
            let presetIndex = angleToPresetIndex(angle)
            if currentIndex != presetIndex {
                currentIndex = presetIndex
                activatePreset(at: presetIndex)
                delegate?.choosePresetPickerView(self, didSelectPresetAt: presetIndex)
            }
        }
        if gesture.state == .ended || gesture.state == .cancelled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.resetToHorizontalMode()
            }
        }
    }

    private func angleToPresetIndex(_ angle: CGFloat) -> Int {
        var normalizedAngle = angle
        if normalizedAngle < 0 {
            normalizedAngle += 2 * CGFloat.pi
        }
        let degrees = normalizedAngle * 180 / CGFloat.pi
        if degrees >= 157.5 && degrees <= 202.5 {
            return 0
        } else if degrees >= 202.5 && degrees < 247.5 {
            return 1
        } else if degrees >= 247.5 && degrees < 292.5 {
            return 2
        } else if degrees >= 292.5 && degrees < 337.5 {
            return 3
        } else if degrees >= 337.5 || degrees < 22.5 {
            return 4
        } else {
            return 2
        }
    }

    private func activatePreset(at index: Int) {
        selectedPresetIndex = index // Track the selected preset
        for (i, preset) in presetViews.enumerated() {
            if i == index {
                preset.backgroundColor = .black
                preset.layer.borderColor = UIColor.white.cgColor
                preset.alpha = 1.0 // High opacity for selected
            } else {
                preset.backgroundColor = .darkGray
                preset.layer.borderColor = UIColor.clear.cgColor
                preset.alpha = 0.4 // Lower opacity for unselected
            }
        }
        hapticFeedback.impactOccurred()
    }

    private func resetToHorizontalMode() {
        hasUserInteracted = false
        isCircularMode = false
        currentIndex = nil
        
        layoutPresetsHorizontally()
        for (index, preset) in presetViews.enumerated() {
            preset.backgroundColor = .darkGray
            preset.layer.borderColor = UIColor.clear.cgColor
            preset.alpha = (index == selectedPresetIndex) ? 1.0 : 0.4
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isCircularMode {
            layoutPresetsCircular()
        } else {
            layoutPresetsHorizontally()
        }
    }
}
