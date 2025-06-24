//
//  DrawingModeModel.swift
//  wedraw
//
//  Created by Ali An Nuur on 22/06/25.
//

import UIKit
import Foundation

enum DrawingMode: CaseIterable, Codable, Equatable, Hashable {
  case reference
  case liveAR

  var title: String {
    switch self {
    case .reference: return "Draw with Reference"
    case .liveAR:    return "Live Draw with Guideline"
    }
  }

  var image: UIImage {
    switch self {
    case .reference: return UIImage(named: "reference_image")!
    case .liveAR:    return UIImage(named: "live_image")!
    }
  }

  var description: String {
    switch self {
    case .reference:
      return "Display step-by-step Loomis head guideline from your chosen angle as a reference. No anchor needed, just follow along with your reference. Your session saved automatically."
    case .liveAR:
      return "Display step-by-step Loomis head guideline from your chosen angle using AR by capturing a photo of an object. Your session saved automatically. Use tripod or glass for better experience."
    }
  }
}
