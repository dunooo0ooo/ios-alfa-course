
class PlaylistDetailRouter: PlaylistDetailRouterInput {
    weak var viewController: UIViewController?

    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
