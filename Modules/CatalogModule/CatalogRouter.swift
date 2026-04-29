import UIKit

final class CatalogRouter: CatalogRouterInput {
    weak var viewController: UIViewController?

    func openTrackDetail(id: String, title: String, subtitle: String?) {
        guard let navigationController = viewController?.navigationController else { return }

        let detailVC = PlaylistDetailViewController()
        detailVC.playlistId = id
        detailVC.trackTitle = title
        detailVC.trackSubtitle = subtitle
        detailVC.title = "Трек"

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
        presenter.didLoad(playlistId: id)
    }

    func openAuthModule() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }

    func openBDUIScreen() {
        let controller = BDUIScreenViewController(descriptor: .demo)
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
