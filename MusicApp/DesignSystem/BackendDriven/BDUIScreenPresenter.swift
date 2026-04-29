import Foundation

final class BDUIScreenPresenter: BDUIScreenPresenterInput, BDUIScreenInteractorOutput {
    weak var view: BDUIScreenView?
    var interactor: BDUIScreenInteractorInput?
    var router: BDUIScreenRouterInput?

    private let configuration: BDUIScreenConfiguration

    var title: String { configuration.title }

    init(configuration: BDUIScreenConfiguration) {
        self.configuration = configuration
    }

    func didLoad() {
        renderLoading()
        interactor?.loadScreen()
    }

    func didTapRetry() {
        renderLoading()
        interactor?.loadScreen()
    }

    func didTrigger(action: BDUIAction) {
        switch action {
        case .print(let message):
            print("BDUI action:", message)
        case .reload:
            didTapRetry()
        case .navigateBack:
            router?.navigateBack()
        case .selectTrack(let id, let title, let subtitle):
            print("BDUI action: selectTrack", id, title, subtitle ?? "")
        }
    }

    func presentContent(_ node: BDUIViewNode) {
        view?.render(.content(node))
    }

    func presentError(_ error: Error) {
        let mapped = (error as? NetworkError) ?? NetworkError.map(error)
        view?.render(.error(
            title: "Не удалось загрузить BDUI",
            subtitle: mapped.userMessage,
            actionTitle: "Повторить"
        ))
    }

    private func renderLoading() {
        view?.render(.loading(
            title: configuration.loadingTitle,
            subtitle: configuration.loadingSubtitle
        ))
    }
}
