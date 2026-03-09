
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let authVC = AuthViewController()
        let navController = UINavigationController(rootViewController: authVC)
        
        let presenter = AuthPresenter()
        let interactor = AuthInteractor()
        let router = AuthRouter()
        
        authVC.presenter = presenter
        presenter.view = authVC
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.viewController = authVC
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}
