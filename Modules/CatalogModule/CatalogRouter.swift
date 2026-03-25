import UIKit

final class CatalogRouter: CatalogRouterInput {
    weak var viewController: UIViewController?

    func openPlaylistDetail(with playlistId: String) {
        guard let navigationController = viewController?.navigationController else { return }

        let detailVC = PlaylistDetailViewController()
        detailVC.title = "Плейлист"

        let presenter = PlaylistDetailPresenter()
        let interactor = PlaylistDetailInteractor()
        let router = PlaylistDetailRouter()
        let service = StubPlaylistService()

        detailVC.presenter = presenter
        presenter.view = detailVC
        presenter.router = router
        presenter.interactor = interactor

        interactor.presenter = presenter
        interactor.service = service

        router.viewController = detailVC

        navigationController.pushViewController(detailVC, animated: true)
        presenter.didLoad(playlistId: playlistId)
    }

    func openAuthModule() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
