import UIKit

final class BDUIScreenRouter: BDUIScreenRouterInput {
    weak var viewController: UIViewController?
    var onAction: ((BDUIAction) -> Void)?

    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func dispatch(action: BDUIAction) {
        onAction?(action)
    }
}
