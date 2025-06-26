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
    private var isCircularMode = false
    private var hasUserInteracted = false

    private var player: AVAudioPlayer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupPresets()
        setupGesture()
        prepareSound()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        setupPresets()
        setupGesture()
        prepareSound()
    }

    private func setupPresets() {
        let presetIcons = ["preset_front", "preset_side_right", "preset_quarter", "preset_side_left", "preset_top"]
        for i in 0..<presetCount {
            let presetView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            presetView.layer.cornerRadius = 25
            presetView.backgroundColor = .darkGray
            presetView.contentMode = .scaleAspectFit
            presetView.image = UIImage(named: presetIcons[i])
            presetView.layer.borderWidth = 2
            presetView.layer.borderColor = UIColor.clear.cgColor
            presetView.isUserInteractionEnabled = false
            addSubview(presetView)
            presetViews.append(presetView)
        }
        layoutPresetsHorizontally()
    }
    
    private func layoutPresetsHorizontally() {
        let spacing: CGFloat = 70
        let totalWidth = CGFloat(presetCount - 1) * spacing
        let startX = bounds.midX - totalWidth / 2
        let y = bounds.midY
        for (index, preset) in presetViews.enumerated() {
            let x = startX + CGFloat(index) * spacing
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                preset.center = CGPoint(x: x, y: y)
                preset.frame.size = CGSize(width: 35, height: 35)
                preset.layer.cornerRadius = 17.5
            }, completion: nil)
        }
    }
    
    private func layoutPresetsCircular() {
        let radius: CGFloat = 120
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        for (index, preset) in presetViews.enumerated() {
            let angle = CGFloat.pi + (CGFloat(index) / CGFloat(presetCount - 1) * CGFloat.pi)
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
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
        for (i, preset) in presetViews.enumerated() {
            if i == index {
                preset.backgroundColor = .black
                preset.layer.borderColor = UIColor.white.cgColor
            } else {
                preset.backgroundColor = .darkGray
                preset.layer.borderColor = UIColor.clear.cgColor
            }
        }
        hapticFeedback.impactOccurred()
        player?.play()
    }

    private func prepareSound() {
        guard let url = Bundle.main.url(forResource: "tick", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Failed to load sound: \(error)")
        }
    }

    private func resetToHorizontalMode() {
        hasUserInteracted = false
        isCircularMode = false
        currentIndex = nil
        layoutPresetsHorizontally()
        for preset in presetViews {
            preset.backgroundColor = .darkGray
            preset.layer.borderColor = UIColor.clear.cgColor
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
