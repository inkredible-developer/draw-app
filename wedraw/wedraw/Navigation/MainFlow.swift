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
    case arTracingViewController(UIImage, UIImage, drawId: UUID)
    case drawingStepsViewController(UUID)
    case setAngleViewController
    case photoCaptureSheetVIewController
    
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
        case .drawingStepsViewController:
            return "Drawing Steps"
        case .photoCaptureSheetVIewController:
            return "Photo Capture"
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
        case .arTracingViewController(let image, let referenceImage, let drawId):
            return ARTracingViewController(anchorImage: image, tracingImage: referenceImage, drawId: drawId)
        case .drawingStepsViewController(let id):
            return DrawingStepsViewController(drawID: id)
        case .setAngleViewController:
            return SetAngleViewController()
        case .photoCaptureSheetVIewController:
            return PhotoCaptureSheetViewController()
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
            case .tutorialSheetViewController(let drawingMode, let angle):
                let vc = TutorialSheetViewController(mode: drawingMode, angle: angle)
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            case .arTracingViewController(let image, let referenceImage, let drawId):
                let vc = ARTracingViewController(anchorImage: image, tracingImage: referenceImage, drawId: drawId)
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
            case .drawingStepsViewController(let id):
                let vc = DrawingStepsViewController(drawID: id)
                if let typedRouter = router as? MainFlowRouter {
                    vc.router = typedRouter
                }
                return vc
            case .photoCaptureSheetVIewController:
                let vc = PhotoCaptureSheetViewController()
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
        case (.drawingStepsViewController(let lhsMode), .drawingStepsViewController(let rhsMode)):
            return lhsMode == rhsMode
        case (.photoCaptureSheetVIewController, .photoCaptureSheetVIewController):
            return true
        default:
            return false
        }
    }
}

typealias MainFlowRouter = Router<MainFlow>
