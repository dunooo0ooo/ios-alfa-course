import UIKit

class AuthRouter: AuthRouterInput {
    weak var viewController: UIViewController?
    
    func openCatalogModule(with userId: String) {
        let catalogVC = CatalogViewController()
        catalogVC.title = "Подборка плейлистов"
        catalogVC.catalogUserId = userId

        let presenter = CatalogPresenter()
        let interactor = CatalogInteractor()
        let router = CatalogRouter()
        let networkClient = URLSessionNetworkClient()
        let catalogService = RemoteCatalogService(networkClient: networkClient)

        catalogVC.interactor = interactor
        presenter.view = catalogVC
        presenter.router = router

        interactor.presenter = presenter
        interactor.service = catalogService

        router.viewController = catalogVC

        viewController?.navigationController?.pushViewController(catalogVC, animated: true)
    }
}
