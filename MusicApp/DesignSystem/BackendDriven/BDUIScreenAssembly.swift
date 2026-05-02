import UIKit

enum BDUIScreenAssembly {
    static func make(
        configuration: BDUIScreenConfiguration,
        service: BDUIScreenProviding = RemoteBDUIScreenService(),
        mapper: BDUIViewMapping = BDUIViewMapper(),
        onAction: ((BDUIAction) -> Void)? = nil
    ) -> UIViewController {
        let viewController = BDUIScreenViewController(mapper: mapper)
        let presenter = BDUIScreenPresenter(configuration: configuration)
        let interactor = BDUIScreenInteractor(configuration: configuration, service: service)
        let router = BDUIScreenRouter()

        viewController.presenter = presenter

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        router.viewController = viewController
        router.onAction = onAction

        return viewController
    }
}
