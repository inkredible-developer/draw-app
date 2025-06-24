//
//  Router.swift
//  wedraw
//
//  Created by Ali An Nuur on 23/06/25.
//

// Router.swift for UIKit
import UIKit

protocol NavigationDestination {
    var title: String { get }
    func createViewController() -> UIViewController
    func createViewControllerWithRouter<T: NavigationDestination>(_ router: Router<T>) -> UIViewController
}

extension NavigationDestination {
    // Default implementation that doesn't use router
    func createViewControllerWithRouter<T: NavigationDestination>(_ router: Router<T>) -> UIViewController {
        return createViewController()
    }
}

final class Router<Destination: NavigationDestination>: NSObject {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func navigate(to destination: Destination, animated: Bool = true) {
           // Use the new method that injects the router
           let viewController = destination.createViewControllerWithRouter(self)
           viewController.title = destination.title
           navigationController?.pushViewController(viewController, animated: animated)
       }
       
    
    func navigateBack(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func navigateToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    func navigateTo(_ destination: Destination, animated: Bool) where Destination: Equatable {
      if let stack = navigationController?.viewControllers {
          if let vc = stack.first(where: { type(of: $0) == type(of: destination.createViewController()) }) {
          navigationController?.popToViewController(vc, animated: animated)
          return
        }
      }
      navigate(to: destination, animated: animated)
    }
    
    func present(_ destination: Destination, animated: Bool = true) {
      let vc = destination.createViewControllerWithRouter(self)
      vc.title = destination.title
      navigationController?.present(UINavigationController(rootViewController: vc),
                                    animated: animated)
    }
    
    func presentDirectly(_ destination: Destination, animated: Bool = true) {
      let vc = destination.createViewControllerWithRouter(self)
      navigationController?.present(vc, animated: animated)
    }
    
    func setRoot(to destination: Destination, animated: Bool = true) {
        let viewController = destination.createViewController()
        viewController.title = destination.title
        navigationController?.setViewControllers([viewController], animated: animated)
    }
    
}
