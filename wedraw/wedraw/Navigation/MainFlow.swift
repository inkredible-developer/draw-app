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
    case photoCaptureSheetViewController(UIImage, UUID, Bool)
    case contourDetectionViewController(UIImage, UIImage, UUID)
    case cameraTesterViewController
    case finishedDrawingViewController(UUID, Int, UIImage)
    case loomishDetailViewController
    case listFinishedDrawingViewController(Draw)
    
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
        case .photoCaptureSheetViewController:
            return "Photo Capture"
        case .contourDetectionViewController:
            return "Contour Detection"
        case .cameraTesterViewController:
            return "Camera Tester"
        case .finishedDrawingViewController:
            return "Finished Drawing"
        case .loomishDetailViewController:
            return "Loomish Detail"
        case .listFinishedDrawingViewController:
            return "List Finished Drawings"
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
        case .photoCaptureSheetViewController(let uiImage, let drawId, let isFinished):
            return PhotoCaptureSheetViewController(tracingImage: uiImage, drawId: drawId, isFinished: isFinished)
        case .contourDetectionViewController(let referenceImage, let userPhoto, let drawId):
            return ContourDetectionViewController(referenceImage: referenceImage, userDrawingImage: userPhoto, drawId: drawId)
        case .cameraTesterViewController:
            return CameraTesterViewController()
        case .finishedDrawingViewController(let drawId, let similarity, let userPhoto):
            return FinishedDrawingViewController(drawID: drawId, similarityScore: similarity, userPhoto: userPhoto)
        case .loomishDetailViewController:
            return LoomishDetailViewController()
        case .listFinishedDrawingViewController(let drawData):
            return ListFinishedDrawingViewController(drawData: drawData)
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
        case .photoCaptureSheetViewController(let uiImage, let drawId, let isFinished):
            let vc = PhotoCaptureSheetViewController(tracingImage: uiImage, drawId: drawId, isFinished: isFinished)
            if let typedRouter = router as? MainFlowRouter {
                vc.router = typedRouter
            }
            return vc
        case .contourDetectionViewController(let referenceImage, let userPhoto, let drawId):
            let vc = ContourDetectionViewController(referenceImage: referenceImage, userDrawingImage: userPhoto, drawId: drawId)
            if let typedRouter = router as? MainFlowRouter {
                vc.router = typedRouter
            }
            return vc
        case .cameraTesterViewController:
            let vc = CameraTesterViewController()
            if let typedRouter = router as? MainFlowRouter {
                vc.router = typedRouter
            }
            return vc
        case .finishedDrawingViewController(let drawId, let similarity, let userPhoto):
            let vc = FinishedDrawingViewController(drawID: drawId, similarityScore: similarity, userPhoto: userPhoto)
            if let typedRouter = router as? MainFlowRouter {
                vc.router = typedRouter
            }
            return vc
        case .loomishDetailViewController:
            let vc = LoomishDetailViewController()
            if let typedRouter = router as? MainFlowRouter {
                vc.router = typedRouter
            }
            return vc
        case .listFinishedDrawingViewController(let drawData):
            let vc = ListFinishedDrawingViewController(drawData: drawData)
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
//        case (.tutorialSheetViewController(let lhsMode), .tutorialSheetViewController(let rhsMode)):
//            return lhsMode == rhsMode
        case let (.tutorialSheetViewController(lhsMode, lhsAngle),
                  .tutorialSheetViewController(rhsMode, rhsAngle)):
            return lhsMode == rhsMode && lhsAngle == rhsAngle
        case (.setAngleViewController, .setAngleViewController):
            return true
        case (.drawingStepsViewController(let lhsMode), .drawingStepsViewController(let rhsMode)):
            return lhsMode == rhsMode
        case (.arTracingViewController, .arTracingViewController):
            return true
//        case (.photoCaptureSheetViewController(let lhsMode), .photoCaptureSheetViewController(let rhsMode)):
//            return lhsMode == rhsMode
        case let (.photoCaptureSheetViewController(lhsImage, lhsId, lhsFinished),
                  .photoCaptureSheetViewController(rhsImage, rhsId, rhsFinished)):
            return lhsImage == rhsImage && lhsId == rhsId && lhsFinished == rhsFinished
//        case (.contourDetectionViewController(let lhsMode), .contourDetectionViewController(let rhsMode)):
//            return lhsMode == rhsMode
        case let (.contourDetectionViewController(lhsRefImage, lhsUserPhoto, lhsDrawId),
                  .contourDetectionViewController(rhsRefImage, rhsUserPhoto, rhsDrawId)):
            return lhsRefImage == rhsRefImage &&
                   lhsUserPhoto == rhsUserPhoto &&
                   lhsDrawId == rhsDrawId
        case (.cameraTesterViewController, .cameraTesterViewController):
            return true
        case (.loomishDetailViewController, .loomishDetailViewController):
            return true
        default:
            return false
        }
    }
}

typealias MainFlowRouter = Router<MainFlow>
