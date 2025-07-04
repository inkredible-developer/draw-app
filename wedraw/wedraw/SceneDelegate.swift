//
//  SceneDelegate.swift
//  wedraw
//
//  Created by Ali An Nuur on 20/06/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var router: MainFlowRouter?
    var cameraCoordinator: CameraCoordinator?
    var photoCaptureCoordinator: PhotoCaptureCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
//
        let window = UIWindow(windowScene: windowScene)
                
        // Check if user has completed onboarding
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            showOnboarding(in: window)
        } else {
            setupMainInterface(in: window)
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
            
    private func showOnboarding(in window: UIWindow) {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onboardingCompleted = { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self?.setupMainInterface(in: window)
        }
        window.rootViewController = onboardingVC
    }
            
    private func setupMainInterface(in window: UIWindow) {
        InitialDataSeeder.seedPresetAngle()
        let mainVC = HomeViewController()
//        let mainVC = CameraModePickerViewController()
//        let mainVC = PhotoCaptureSheetViewController(tracingImage: UIImage(named: "tracingImage")!)

        
//        InitialDataSeeder.seedDrawIfNeeded()
//        let mainVC = SelectDrawingViewController()
//        let mainVC = DrawingStepsViewController()
//        let mainVC = DrawingStepsUsingCameraController()
//        let mainVC = SetAngleViewController()
        
        let mainNavigationController = UINavigationController(rootViewController: mainVC)
        router = MainFlowRouter(navigationController: mainNavigationController)
        
        mainVC.router = router
        
        // Animate transition if changing from onboarding
        if window.rootViewController is OnboardingViewController {
            window.rootViewController = mainNavigationController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } else {
            window.rootViewController = mainNavigationController
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

