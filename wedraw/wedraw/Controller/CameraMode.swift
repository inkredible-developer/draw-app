import UIKit

// 1. Data Model
struct CameraMode {
    let icon: UIImage
    let title: String
}

// 2. Carousel Layout untuk efek scale di tengah
class CarouselFlowLayout: UICollectionViewFlowLayout {
    let activeDistance: CGFloat = 80
    let zoomFactor: CGFloat = 0.33
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: (collectionView!.bounds.width - itemSize.width)/2,
                                    bottom: 0, right: (collectionView!.bounds.width - itemSize.width)/2)
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard let collectionView = collectionView else { return attributes }
        let centerX = collectionView.contentOffset.x + collectionView.bounds.size.width/2
        attributes?.forEach {
            let distance = abs($0.center.x - centerX)
            let normalized = distance/activeDistance
            let zoom = 1 + zoomFactor*(1 - min(normalized, 1))
            $0.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
            $0.alpha = zoom > 1.05 ? 1 : 0.35
            $0.zIndex = Int(zoom*10)
        }
        return attributes
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
    // Snap to center
    override func targetContentOffset(forProposedContentOffset proposed: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposed }
        let rect = CGRect(origin: proposed, size: collectionView.bounds.size)
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return proposed }
        let centerX = proposed.x + collectionView.bounds.size.width / 2
        let closest = attributes.min(by: { abs($0.center.x - centerX) < abs($1.center.x - centerX) }) ?? UICollectionViewLayoutAttributes()
        let offset = closest.center.x - centerX
        return CGPoint(x: proposed.x + offset, y: proposed.y)
    }
}

// 3. Mode Cell
class ModeCarouselCell: UICollectionViewCell {
    static let reuseID = "ModeCarouselCell"
    let iconView = UIImageView()
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 2),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 2),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -2),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(mode: CameraMode, highlight: Bool) {
        iconView.image = mode.icon
        titleLabel.text = mode.title
        titleLabel.font = highlight
        ? UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .heavy)
        //        UIFont.systemFont(ofSize: 18, weight: .heavy)
        : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .regular)
        //        UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = highlight ? .yellow : .white.withAlphaComponent(0.75)
    }
}

// 4. Main ViewController (bisa dipanggil langsung)
class CameraModePickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    var router: MainFlowRouter?
    
    let modes: [CameraMode] = [
        .init(icon: UIImage(systemName: "camera")!, title: "Photo"),
        .init(icon: UIImage(systemName: "person.crop.square")!, title: "Portrait"),
        .init(icon: UIImage(systemName: "video")!, title: "Video"),
        .init(icon: UIImage(systemName: "timer")!, title: "Time-lapse"),
        .init(icon: UIImage(systemName: "moon")!, title: "Night"),
        .init(icon: UIImage(systemName: "camera.macro")!, title: "Macro"),
        .init(icon: UIImage(systemName: "livephoto")!, title: "Live"),
        .init(icon: UIImage(systemName: "sparkles")!, title: "Pano"),
    ]
    var selectedIndex = 0
    
    // UI
    let lightingButton = UIButton(type: .system)
    let dimView = UIView()
    let modalSheet = UIView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    let carousel: UICollectionView
    let feedback = UISelectionFeedbackGenerator()
    
    var modalBottomConstraint: NSLayoutConstraint!
    
    init() {
        let layout = CarouselFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 90)
        self.carousel = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLightingButton()
        setupModalSheet()
    }
    
    // Tombol utama lightingButton
    func setupLightingButton() {
        lightingButton.setImage(modes[selectedIndex].icon.withRenderingMode(.alwaysTemplate), for: .normal)
        lightingButton.setTitle("  \(modes[selectedIndex].title)", for: .normal)
        lightingButton.tintColor = .white
        lightingButton.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .semibold)
        //        lightingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        lightingButton.backgroundColor = UIColor(white: 0.25, alpha: 0.65)
        lightingButton.layer.cornerRadius = 22
        lightingButton.clipsToBounds = true
//        lightingButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 28, bottom: 12, right: 28)
        lightingButton.translatesAutoresizingMaskIntoConstraints = false
        lightingButton.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        view.addSubview(lightingButton)
        NSLayoutConstraint.activate([
            lightingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36),
            lightingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // Modal Sheet (blur, rounded, shadow, carousel)
    func setupModalSheet() {
        // Dim background
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.01)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeModal)))
        view.insertSubview(dimView, belowSubview: lightingButton)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dimView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        // Modal container
        modalSheet.translatesAutoresizingMaskIntoConstraints = false
        modalSheet.layer.cornerRadius = 34
        modalSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        modalSheet.clipsToBounds = true
        modalSheet.layer.shadowColor = UIColor.black.cgColor
        modalSheet.layer.shadowRadius = 15
        modalSheet.layer.shadowOpacity = 0.25
        modalSheet.layer.shadowOffset = CGSize(width: 0, height: -6)
        modalSheet.alpha = 0
        view.addSubview(modalSheet)
        
        // Blur
        blurView.translatesAutoresizingMaskIntoConstraints = false
        modalSheet.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: modalSheet.topAnchor),
            blurView.leftAnchor.constraint(equalTo: modalSheet.leftAnchor),
            blurView.rightAnchor.constraint(equalTo: modalSheet.rightAnchor),
            blurView.bottomAnchor.constraint(equalTo: modalSheet.bottomAnchor)
        ])
        
        // Carousel
        carousel.backgroundColor = .clear
        carousel.register(ModeCarouselCell.self, forCellWithReuseIdentifier: ModeCarouselCell.reuseID)
        carousel.dataSource = self
        carousel.delegate = self
        carousel.showsHorizontalScrollIndicator = false
        carousel.decelerationRate = .fast
        carousel.translatesAutoresizingMaskIntoConstraints = false
        modalSheet.addSubview(carousel)
        
        modalBottomConstraint = modalSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 350)
        NSLayoutConstraint.activate([
            modalSheet.heightAnchor.constraint(equalToConstant: 170),
            modalSheet.leftAnchor.constraint(equalTo: view.leftAnchor),
            modalSheet.rightAnchor.constraint(equalTo: view.rightAnchor),
            modalBottomConstraint
        ])
        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: modalSheet.topAnchor, constant: 32),
            carousel.bottomAnchor.constraint(equalTo: modalSheet.bottomAnchor, constant: -14),
            carousel.leftAnchor.constraint(equalTo: modalSheet.leftAnchor),
            carousel.rightAnchor.constraint(equalTo: modalSheet.rightAnchor)
        ])
    }
    
    // Buka modal (morph anim)
    @objc func openModal() {
        // Snap posisi carousel ke mode terpilih
        carousel.layoutIfNeeded()
        carousel.reloadData()
        carousel.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        feedback.selectionChanged()
        // Animasi morph
        self.lightingButton.isUserInteractionEnabled = false
        let btnSnapshot = lightingButton.snapshotView(afterScreenUpdates: false)!
        btnSnapshot.frame = lightingButton.frame
        btnSnapshot.layer.cornerRadius = lightingButton.layer.cornerRadius
        view.addSubview(btnSnapshot)
        lightingButton.alpha = 0
        modalSheet.alpha = 1
        dimView.alpha = 0.01
        view.bringSubviewToFront(modalSheet)
        modalBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.36, delay: 0, usingSpringWithDamping: 0.93, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            btnSnapshot.transform = CGAffineTransform(translationX: 0, y: -145).scaledBy(x: 3.3, y: 1.5)
            btnSnapshot.alpha = 0.0
            self.modalSheet.transform = CGAffineTransform(translationX: 0, y: -36)
            self.modalSheet.alpha = 1
            self.dimView.alpha = 0.32
            self.view.layoutIfNeeded()
        }, completion: { _ in
            btnSnapshot.removeFromSuperview()
            self.modalSheet.transform = .identity
            self.lightingButton.isUserInteractionEnabled = true
        })
    }
    // Tutup modal + update mode
    @objc func closeModal() {
        modalBottomConstraint.constant = 350
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut, animations: {
            self.modalSheet.alpha = 0
            self.dimView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.modalSheet.transform = .identity
        })
    }
    
    // DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { modes.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModeCarouselCell.reuseID, for: indexPath) as! ModeCarouselCell
        let center = collectionView.convert(cell.center, to: collectionView.superview)
        let isCenter = abs(center.x - view.center.x) < 45
        cell.configure(mode: modes[indexPath.item], highlight: isCenter)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectMode(index: indexPath.item)
    }
    // Snap to center & haptic feedback
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = carousel.collectionViewLayout as? CarouselFlowLayout else { return }
        let itemWidth = layout.itemSize.width
        let proposedX = targetContentOffset.pointee.x + carousel.bounds.width / 2
        let item = round((proposedX - layout.sectionInset.left) / itemWidth)
        let clamped = Int(max(0, min(CGFloat(modes.count-1), item)))
        let x = CGFloat(clamped) * itemWidth + layout.sectionInset.left - carousel.bounds.width/2 + itemWidth/2
        targetContentOffset.pointee.x = x
        // Haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) { [weak self] in
            self?.feedback.selectionChanged()
            self?.carousel.reloadData()
        }
    }
    // Update mode saat stop scroll
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { snapToCenter() }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { snapToCenter() }
    }
    func snapToCenter() {
        let centerPoint = CGPoint(x: carousel.bounds.midX + carousel.contentOffset.x, y: carousel.bounds.midY)
        if let idx = carousel.indexPathForItem(at: centerPoint) {
            feedback.selectionChanged()
            carousel.scrollToItem(at: idx, at: .centeredHorizontally, animated: true)
            selectedIndex = idx.item
            carousel.reloadData()
        }
    }
    func selectMode(index: Int) {
        selectedIndex = index
        carousel.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        feedback.selectionChanged()
        // Delay animasi close modal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            self.lightingButton.setImage(self.modes[index].icon.withRenderingMode(.alwaysTemplate), for: .normal)
            self.lightingButton.setTitle("  \(self.modes[index].title)", for: .normal)
            self.closeModal()
            self.lightingButton.alpha = 1
        }
    }
}
