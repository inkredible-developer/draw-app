import UIKit

class CameraTesterViewController: UIViewController, CameraTesterViewDelegate {
    var router: MainFlowRouter?
    private let cameraTesterView = CameraTesterView()
    private var loadingView: LoadingPageView?
    
    override func loadView() {
        view = cameraTesterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraTesterView.delegate = self
    }
    
    func cameraTesterViewDidTapCancel(_ view: CameraTesterView) {
        navigationController?.popViewController(animated: true)
    }
    
    func cameraTesterViewDidTapNext(_ view: CameraTesterView) {
        // Show loading splash as full-screen overlay
        let loading = LoadingPageView(frame: view.bounds)
        loading.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView = loading
        
        // Add to the current view controller's view
        self.view.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.topAnchor.constraint(equalTo: self.view.topAnchor),
            loading.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            loading.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loading.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // After delay, present FinishedDrawingViewController as full-screen modal
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.loadingView?.removeFromSuperview()
            let finishedVC = FinishedDrawingViewController()
            finishedVC.router = self.router
            
            // Wrap in navigation controller to get navigation bar
            let navController = UINavigationController(rootViewController: finishedVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
} 