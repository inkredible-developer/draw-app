//
//  onBoardingViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 23/06/25.
//
import UIKit

// MARK: – Model
struct OnboardingPage {
  let title: String
  let description: String
}

// MARK: – ViewController
class OnboardingViewController: UIViewController {
  
    var onboardingCompleted: (() -> Void)?
    
  // 1) Data
  private let pages: [OnboardingPage] = [
    .init(title: "Welcome To WeDraw",
          description: "WeDraw helps you draw human heads accurately using step-by-step Loomis head guidelines."),
    .init(title: "Two Ways to Draw",
          description: "Use AR and an anchor to draw with guidance, or simply follow Loomis steps beside a reference image."),
    .init(title: "One Step at a Time",
          description: "Each drawing session guides you through structured steps from basic shapes to full facial features.")
  ]
  
  // 2) UI
  private let backgroundImageView = UIImageView()
  private let scrollView = UIScrollView()
  private let pageControl = UIPageControl()
  private let nextButton = UIButton(type: .system)
    
    private lazy var actionButton = CustomButton(
        backgroundColor: UIColor(named: "Inkredible-Green") ?? .systemGreen,
        titleColor: UIColor(named: "Inkredible-DarkText") ?? .systemRed
    )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
      actionButton.delegate = self
    setupBackground()
    setupScrollView()
    setupOverlayControls()
    layoutPages()
    updateOverlay(animated: false)
  }
  
  // MARK: – Setup background
  private func setupBackground() {
    // gunakan panorama yang lebarnya = screenWidth * pages.count
    backgroundImageView.image = UIImage(named: "onboarding_panorama")
    backgroundImageView.contentMode = .scaleAspectFill
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backgroundImageView)
    NSLayoutConstraint.activate([
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      // width = pages.count × view.width
      backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                 multiplier: CGFloat(pages.count))
    ])
  }
  
  // MARK: – Setup scrollView
  private func setupScrollView() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    scrollView.backgroundColor = .clear
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  // MARK: – Lay out each “page”’s labels & set contentSize
  private func layoutPages() {
    let w = view.bounds.width
    let h = view.bounds.height
    scrollView.contentSize = CGSize(width: w * CGFloat(pages.count), height: h)
    
    for (i, page) in pages.enumerated() {
      let container = UIView(frame: CGRect(x: CGFloat(i)*w, y: 0, width: w, height: h))
      container.backgroundColor = .clear
      
      // Title
      let titleLabel = UILabel()
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.text = page.title
      titleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .bold)
        titleLabel.textColor = .white
      titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
      container.addSubview(titleLabel)
      
      // Description
      let descLabel = UILabel()
      descLabel.translatesAutoresizingMaskIntoConstraints = false
      descLabel.text = page.description
      descLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)
      descLabel.textColor = UIColor(named: "Inkredible-onDesc")
      descLabel.numberOfLines = 0
      descLabel.textAlignment = .left
      container.addSubview(descLabel)
      
        NSLayoutConstraint.activate([
                    descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -(32 + 44 + 44 + 44 + 16)), // 32 bottom margin + 44 button height + 16 pageControl gap + 16 descLabel gap
                    descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
                    descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
                    
                    titleLabel.bottomAnchor.constraint(equalTo: descLabel.topAnchor, constant: -8),
                    titleLabel.leadingAnchor.constraint(equalTo: descLabel.leadingAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo: descLabel.trailingAnchor)
                ])
        
      
      scrollView.addSubview(container)
    }
  }
  
  // MARK: – PageControl & Next button
  private func setupOverlayControls() {
      actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.layer.cornerRadius = 20
        view.addSubview(actionButton)
    
    // PageControl
    pageControl.numberOfPages = pages.count
    pageControl.currentPage = 0
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(pageControl)
    
      NSLayoutConstraint.activate([
        actionButton.heightAnchor.constraint(equalToConstant: 55),
        actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
        actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
        
        pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -16),
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor) ])
      
  }
  
  // MARK: – Update CTL when index changes
  private var currentPage = 0 {
    didSet { updateOverlay(animated: true) }
  }
  private func updateOverlay(animated: Bool) {
    let last = currentPage == pages.count - 1
      actionButton.setTitle(last ? "Get Started" : "Next", for: .normal)
    pageControl.currentPage = currentPage
    
    // animate background shift
    let targetX = -view.bounds.width * CGFloat(currentPage)
    let animations = { self.backgroundImageView.transform = .init(translationX: targetX, y: 0) }
    if animated {
      UIView.animate(withDuration: 0.4, animations: animations)
    } else {
      animations()
    }
  }
  
}

extension OnboardingViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Calculate the proportional offset for the background
    let pageWidth = view.bounds.width
    let offsetRatio = scrollView.contentOffset.x / (pageWidth * CGFloat(pages.count - 1))
    let maxBackgroundOffset = view.bounds.width * CGFloat(pages.count - 1)
    let backgroundOffset = -offsetRatio * maxBackgroundOffset
    
    // Update background position in real-time
    backgroundImageView.transform = .init(translationX: backgroundOffset, y: 0)
  }
  
  func scrollViewDidEndDecelerating(_ sv: UIScrollView) {
    let page = Int(round(sv.contentOffset.x / view.bounds.width))
    currentPage = page
  }
  
  func scrollViewDidEndScrollingAnimation(_ sv: UIScrollView) {
    // when programmatic scroll finishes
    scrollViewDidEndDecelerating(sv)
  }
}

extension OnboardingViewController : CustomButtonDelegate {
  func customButtonDidTap(_ button: CustomButton) {
    let next = currentPage + 1
    
    if currentPage == pages.count - 1 {
//        print("GAS")
        onboardingCompleted?()
      return
    }
    
    let offset = CGPoint(x: view.bounds.width * CGFloat(next), y: 0)
    scrollView.setContentOffset(offset, animated: true)
  }
}
