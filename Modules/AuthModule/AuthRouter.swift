import UIKit

class AuthRouter: AuthRouterInput {
    weak var viewController: UIViewController?

    func openCatalogModule(with userId: String) {
        // будет переход к CatalogModule
        // Например: let catalogVC = CatalogViewController()
        // viewController?.navigationController?.pushViewController(catalogVC, animated: true)
    }
}
