import UIKit

class AuthRouter: AuthRouterInput {
    weak var viewController: UIViewController?
    
    func openCatalogModule(with userId: String) {
        let catalogVC = CatalogViewController()
        catalogVC.title = "Подборка плейлистов"
        viewController?.navigationController?.pushViewController(catalogVC, animated: true)
    }
}
