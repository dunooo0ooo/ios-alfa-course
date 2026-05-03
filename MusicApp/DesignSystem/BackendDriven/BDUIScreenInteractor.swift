import Foundation

final class BDUIScreenInteractor: BDUIScreenInteractorInput {
    weak var output: BDUIScreenInteractorOutput?
    var service: BDUIScreenProviding

    private let configuration: BDUIScreenConfiguration
    private var loadTask: Task<Void, Never>?

    init(
        configuration: BDUIScreenConfiguration,
        service: BDUIScreenProviding
    ) {
        self.configuration = configuration
        self.service = service
    }

    func loadScreen() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let node = try await service.fetchScreen(configuration: configuration)
                try Task.checkCancellation()
                await MainActor.run {
                    self.output?.presentContent(node)
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self.output?.presentError(error)
                }
            }
        }
    }
}
