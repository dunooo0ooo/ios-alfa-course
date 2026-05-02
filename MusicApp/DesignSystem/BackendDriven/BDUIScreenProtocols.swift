import UIKit

protocol BDUIScreenView: AnyObject {
    func render(_ state: BDUIScreenViewState)
}

protocol BDUIScreenPresenterInput: AnyObject {
    var title: String { get }
    func didLoad()
    func didTapRetry()
    func didTrigger(action: BDUIAction)
}

protocol BDUIScreenInteractorInput: AnyObject {
    func loadScreen()
}

protocol BDUIScreenInteractorOutput: AnyObject {
    func presentContent(_ node: BDUIViewNode)
    func presentError(_ error: Error)
}

protocol BDUIScreenRouterInput: AnyObject {
    func navigateBack()
    func dispatch(action: BDUIAction)
}
