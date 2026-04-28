import UIKit

final class CatalogRouter: CatalogRouterInput {
    weak var viewController: UIViewController?

    func openAuthModule() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }

    func openBDUIScreen(configuration: BDUIScreenConfiguration) {
        let controller = BDUIScreenAssembly.make(configuration: configuration)
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
