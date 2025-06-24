//
//  ModeCarouselView.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

//
//  ModeCarouselView.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//  Updated by ChatGPT: discrete & swipe animations added.
//
import UIKit

protocol ModeCarouselViewDelegate: AnyObject {
  func carousel(_ carousel: ModeCarouselView, didSelectItemAt index: Int)
}

final class ModeCarouselView: UIView {
  // MARK: – Delegate
  weak var delegate: ModeCarouselViewDelegate?

  // MARK: – UI Components
  private let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.isPagingEnabled = false       // custom snap
    sv.decelerationRate = .fast
//      sv.backgroundColor = .red
    sv.showsHorizontalScrollIndicator = false
    return sv
  }()
    
  private let pageControl: UIPageControl = {
    let pc = UIPageControl()
    pc.translatesAutoresizingMaskIntoConstraints = false
    pc.pageIndicatorTintColor = .systemGray4
//      pc.backgroundColor = .blue
    pc.currentPageIndicatorTintColor = .systemBlue
    return pc
  }()

  // MARK: – Data & Layout
  private let modes = DrawingMode.allCases
  private var cards: [ModeCardView] = []
  private var cardWidth: CGFloat = 0
  private var cardHeight: CGFloat = 0
  private let cardSpacing: CGFloat = 16

  // Scale values
  private let selectedScale: CGFloat = 1.0
  private let unselectedScale: CGFloat = 0.8
  
  // Flag to prevent multiple animations
  private var isAnimatingScroll = false

  // MARK: – State
  private(set) var selectedIndex: Int = 0 {
    didSet {
      guard oldValue != selectedIndex else { return }
      pageControl.currentPage = selectedIndex
      delegate?.carousel(self, didSelectItemAt: selectedIndex)
    }
  }

  // MARK: – Init
  override init(frame: CGRect) {
    super.init(frame: frame)
      
    scrollView.delegate = self
    setupScrollView()
    setupPageControl()
      
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: – Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newW = bounds.width * 0.65
        let newH = bounds.height * 0.7

        if cards.isEmpty || newW != cardWidth || newH != cardHeight {
            cardWidth = newW
            cardHeight = newH

            cards.forEach { $0.removeFromSuperview() }
            cards.removeAll()

            setupCards()

            let contentW = CGFloat(modes.count) * (cardWidth + cardSpacing) + cardSpacing
            scrollView.contentSize = CGSize(width: contentW, height: scrollView.bounds.height)

            let inset = (bounds.width - cardWidth) / 2
            scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            scrollView.scrollIndicatorInsets = scrollView.contentInset

            scrollToPage(selectedIndex, animated: false)
            
            // Ensure the correct scale is applied immediately
            DispatchQueue.main.async {
                self.updateCardScales()
            }
        }
    }

  // MARK: – Setup ScrollView
    private func setupScrollView() {
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -90)
        ])
    }
  // MARK: – Setup Cards
    private func setupCards() {
        for (i, mode) in modes.enumerated() {
            let card = ModeCardView(mode: mode)
            card.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(card)
            cards.append(card)

            // Apply initial scale directly during setup
            let isSelected = i == selectedIndex
            let scale = isSelected ? selectedScale : unselectedScale
            card.transform = CGAffineTransform(scaleX: scale, y: scale)

            let leading = (i == 0) ? scrollView.leadingAnchor : cards[i-1].trailingAnchor
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: cardWidth),
                card.heightAnchor.constraint(equalToConstant: cardHeight),
                card.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
                card.leadingAnchor.constraint(equalTo: leading, constant: cardSpacing)
            ])

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
            card.tag = i
        }
    }

  // MARK: – Setup PageControl
    // Replace the existing setupPageControl() method
    private func setupPageControl() {
        addSubview(pageControl)
        pageControl.numberOfPages = modes.count
        pageControl.currentPage = selectedIndex
        
        // Remove interaction - page control will be display-only
        pageControl.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
  // MARK: – Actions
  @objc private func cardTapped(_ gr: UITapGestureRecognizer) {
    guard let idx = gr.view?.tag, !isAnimatingScroll else { return }
    scrollToPage(idx)
  }

  /// Scrolls to the given page, centers it, and triggers scale animation.
    func scrollToPage(_ page: Int, animated: Bool = true) {
        guard page >= 0 && page < modes.count, !isAnimatingScroll else { return }
        
        if animated {
            isAnimatingScroll = true
        }
        
        // Remove the unused variable warning by using _ instead
        selectedIndex = page

        let inset = scrollView.contentInset.left
        let xOffset = CGFloat(page) * (cardWidth + cardSpacing) + cardSpacing - inset
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.scrollView.contentOffset = CGPoint(x: xOffset, y: 0)
                self.updateCardScales()
            }, completion: { _ in
                self.isAnimatingScroll = false
            })
        } else {
            scrollView.contentOffset = CGPoint(x: xOffset, y: 0)
            updateCardScales()
        }
    }

  // Update all card scales based on their position relative to the center
    private func updateCardScales() {
        // Tentukan skala maksimum (saat di tengah) dan minimum (saat di pinggir)
        let selectedScale: CGFloat = 1.0
        let unselectedScale: CGFloat = 0.8

        // Hitung titik tengah horizontal dari area yang terlihat di scrollView
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2

        for card in cards {
            // Hitung jarak antara pusat kartu dan pusat scrollView
            let distance = abs(card.center.x - centerX)
            
            // Tentukan jarak "ambang batas" di mana transisi skala terjadi.
            // Lebar kartu adalah pilihan yang baik untuk ini.
            let thresholdDistance = card.bounds.width
            
            // Pastikan kita tidak membagi dengan nol jika jaraknya lebih besar dari ambang batas
            if distance < thresholdDistance {
                // Hitung 'progress' dari 0.0 (paling jauh) ke 1.0 (paling dekat/di tengah).
                // Saat kartu tepat di tengah (distance = 0), progress = 1.0.
                // Saat kartu di batas ambang (distance = thresholdDistance), progress = 0.0.
                let progress = 1 - (distance / thresholdDistance)
                
                // Hitung perbedaan skala antara yang terpilih dan tidak
                let scaleDifference = selectedScale - unselectedScale
                
                // Kalkulasi skala saat ini berdasarkan progress
                let scale = unselectedScale + (scaleDifference * progress)
                
                // Terapkan transformasi dengan animasi agar lebih mulus lagi
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    card.transform = CGAffineTransform(scaleX: scale, y: scale)
                }, completion: nil)
                
            } else {
                // Jika kartu berada di luar jarak ambang batas, gunakan skala minimum
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    card.transform = CGAffineTransform(scaleX: unselectedScale, y: unselectedScale)
                }, completion: nil)
            }
        }
    }
}

// MARK: – UIScrollViewDelegate
extension ModeCarouselView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Only update scales during user-initiated scrolling
//    if !isAnimatingScroll {
//      updateNearestCardIndex()
      updateCardScales()
//    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      snapToNearestCard()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    snapToNearestCard()
  }
  
  private func updateNearestCardIndex() {
    let centerX = scrollView.bounds.midX + scrollView.contentOffset.x
    var bestIdx = 0
    var bestDist = CGFloat.greatestFiniteMagnitude
    
    for (i, card) in cards.enumerated() {
      let distance = abs(card.center.x - centerX)
      if distance < bestDist {
        bestDist = distance
        bestIdx = i
      }
    }
    
    if bestIdx != selectedIndex {
      selectedIndex = bestIdx
    }
  }

  private func snapToNearestCard() {
    guard !isAnimatingScroll else { return }
    
    let centerX = scrollView.bounds.midX + scrollView.contentOffset.x
    var bestIdx = 0
    var bestDist = CGFloat.greatestFiniteMagnitude
    
    for (i, card) in cards.enumerated() {
      let distance = abs(card.center.x - centerX)
      if distance < bestDist {
        bestDist = distance
        bestIdx = i
      }
    }
    
    scrollToPage(bestIdx)
  }
}

#Preview {
    ModeCarouselView()
}
