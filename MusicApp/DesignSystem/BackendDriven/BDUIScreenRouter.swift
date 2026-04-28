import UIKit

final class BDUIScreenRouter: BDUIScreenRouterInput {
    weak var viewController: UIViewController?

    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
