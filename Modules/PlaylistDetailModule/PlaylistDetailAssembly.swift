import UIKit

enum PlaylistDetailAssembly {
    static func make(
        playlistId: String,
        trackTitle: String? = nil,
        trackSubtitle: String? = nil,
        service: PlaylistService = StubPlaylistService()
    ) -> UIViewController {
        let viewController = PlaylistDetailViewController()
        let presenter = PlaylistDetailPresenter()
        let interactor = PlaylistDetailInteractor()
        let router = PlaylistDetailRouter()

        viewController.presenter = presenter
        viewController.playlistId = playlistId
        viewController.trackTitle = trackTitle
        viewController.trackSubtitle = trackSubtitle

        presenter.view = viewController
        presenter.router = router
        presenter.interactor = interactor

        interactor.presenter = presenter
        interactor.service = service

        router.viewController = viewController

        return viewController
    }
}

