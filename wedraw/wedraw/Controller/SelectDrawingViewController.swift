//
//  SelectDrawingViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit

final class SelectDrawingViewController: UIViewController {
    var selectedAngle: Angle?
    var drawService: DrawService?
    var router: MainFlowRouter?

  private lazy var carousel = ModeCarouselView()
  private lazy var selectButton = CustomButton(title: "Select", backgroundColor: UIColor(named: "Inkredible-Green") ?? .systemGreen, titleColor: UIColor(named: "Inkredible-DarkText") ?? .systemGreen)

  override func loadView() {
    view = UIView()
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Select Drawing Mode"
    setupSubviews()
    carousel.delegate = self
    selectButton.delegate = self
    
//    if let angle = selectedAngle {
//        print("Selected angle: \(angle.angle_name ?? "-") angle_id: \(angle.angle_id))")
//    }
  }

  private func setupSubviews() {
    [carousel, selectButton].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    NSLayoutConstraint.activate([
      carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      carousel.bottomAnchor.constraint(equalTo: selectButton.topAnchor),
      selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      selectButton.heightAnchor.constraint(equalToConstant: 55)
    ])
  }
}

extension SelectDrawingViewController: ModeCarouselViewDelegate {
  func carousel(_ carousel: ModeCarouselView, didSelectItemAt index: Int) {
    print("Selected mode:", DrawingMode.allCases[index].title)
  }
}

extension SelectDrawingViewController : CustomButtonDelegate {
    func customButtonDidTap(_ button: CustomButton) {
        guard let selectedAngle = selectedAngle, let angleID = selectedAngle.angle_id else {
           print("No angle selected.")
           return
        }
    
        let draw_id = UUID()
        
//        drawService?.createDraw(
//            draw_id: draw_id,
//            angle_id: angleID,
//            draw_mode: "reference"
//        )
        let mode = DrawingMode.allCases[carousel.selectedIndex]
        print("mode",mode)
        router?.presentDirectly(.tutorialSheetViewController(mode,selectedAngle), animated: true)
    }
}

#Preview {
    SelectDrawingViewController()
}
