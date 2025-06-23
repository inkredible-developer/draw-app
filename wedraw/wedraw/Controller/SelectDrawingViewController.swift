//
//  SelectDrawingViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit

final class SelectDrawingViewController: UIViewController {
  private lazy var carousel = ModeCarouselView()
  private lazy var selectButton = CustomButton(title: "Select")

  override func loadView() {
    view = UIView()
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Select Drawing Mode"
    setupSubviews()
    carousel.delegate = self
//      carousel.backgroundColor = .systemGray6
    selectButton.delegate = self
      selectButton.backgroundColor = .systemGreen
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
//      carousel.heightAnchor.constraint(equalTo: view.heightAnchor),

      selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      selectButton.heightAnchor.constraint(equalToConstant: 52)
    ])
  }
}

extension SelectDrawingViewController: ModeCarouselViewDelegate {
  func carousel(_ carousel: ModeCarouselView, didSelectItemAt index: Int) {
    // Contoh: update UI, simpan pilihan, dsb.
    print("Selected mode:", DrawingMode.allCases[index].title)
  }
}

extension SelectDrawingViewController : CustomButtonDelegate {
  func customButtonDidTap(_ button: CustomButton) {
    let mode = DrawingMode.allCases[carousel.selectedIndex]
    let tutorialVC = TutorialSheetViewController(mode: mode)
    present(tutorialVC, animated: true)
  }
}

//extension SelectDrawingViewController: CustomButtonDelegate {
//  func customButtonDidTap(_ button: CustomButton) {
//    let mode = DrawingMode.allCases[carousel.selectedIndex]
//    // Lanjut ke layar drawing sesuai mode
//    switch mode {
//    case .reference:
////      let vc = ReferenceDrawingViewController()
//print("Selected mode: Reference Drawing")
//        //      navigationController?.pushViewController(vc, animated: true)
//    case .liveAR:
//        print("Selected mode: Live AR Drawing")
////      let vc = ARTracingViewController()
////      navigationController?.pushViewController(vc, animated: true)
//    }
//  }
//}

#Preview {
    SelectDrawingViewController()
}
