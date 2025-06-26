//
//  MainFlow.swift
//  wedraw
//
//  Created by Ali An Nuur on 24/06/25.
//

import UIKit

enum MainFlow: NavigationDestination, Equatable {
    case homeViewController
    case selectDrawingViewController(selectedAngle: Angle)
    case tutorialSheetViewController(DrawingMode, Angle)
    case arTracingViewController(UIImage, UIImage)
    case setAngleViewController
    
    var title: String {
        switch self {
        case .homeViewController:
            return "Home"
        case .selectDrawingViewController:
            return "Select Drawing"
        case .tutorialSheetViewController:
            return "Tutorial"
        case .arTracingViewController:
            return "AR Tracing"
        case .setAngleViewController:
            return "Set Angle"
        }
    }
    
    func createViewController() -> UIViewController {
        switch self {
        case .homeViewController:
            return SelectDrawingViewController()
        case .selectDrawingViewController(let selectedAngle):
            let vc = SelectDrawingViewController()
            vc.selectedAngle = selectedAngle
            return vc
        case .tutorialSheetViewController(let drawingMode, let selectedAngle):
            return TutorialSheetViewController(mode: drawingMode, angle: selectedAngle)
        case .arTracingViewController(let image, let referenceImage):
            return ARTracingViewController(anchorImage: image, tracingImage: referenceImage)
        case .setAngleViewController:
            return SetAngleViewController()
        }
    }
    
    func createViewControllerWithRouter<T: NavigationDestination>(_ router: Router<T>) -> UIViewController {
            switch self {
            case .homeViewController:
                let vc = SelectDrawingViewController()
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            case .selectDrawingViewController(let selectedAngle):
                let vc = SelectDrawingViewController()
                vc.selectedAngle = selectedAngle
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            case .tutorialSheetViewController(let drawingMode, let selectedAngle):
                let vc = TutorialSheetViewController(mode: drawingMode, angle: selectedAngle)
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            case .arTracingViewController(let image, let referenceImage):
                let vc = ARTracingViewController(anchorImage: image, tracingImage: referenceImage)
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            case .setAngleViewController:
                let vc = SetAngleViewController()
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            }
        }
    
    static func == (lhs: MainFlow, rhs: MainFlow) -> Bool {
        switch (lhs, rhs) {
        case (.homeViewController, .homeViewController):
            return true
        case (.selectDrawingViewController, .selectDrawingViewController):
            return true
        case (.tutorialSheetViewController(let lhsMode), .tutorialSheetViewController(let rhsMode)):
            return lhsMode == rhsMode
        case (.setAngleViewController, .setAngleViewController):
            return true
        default:
            return false
        }
    }
}

typealias MainFlowRouter = Router<MainFlow>
