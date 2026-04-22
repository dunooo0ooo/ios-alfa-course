import UIKit

final class BDUIScreenViewController: UIViewController, BDUIActionHandling {
    private let service: BDUIScreenProviding
    private let mapper: BDUIViewMapping
    private let descriptor: BDUIScreenDescriptor

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stateView: DSStateView = {
        let view = DSStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.actionHandler = { [weak self] in
            self?.loadScreen()
        }
        return view
    }()

    init(
        descriptor: BDUIScreenDescriptor,
        service: BDUIScreenProviding = EchoBDUIService(),
        mapper: BDUIViewMapping = BDUIViewMapper()
    ) {
        self.descriptor = descriptor
        self.service = service
        self.mapper = mapper
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadScreen()
    }

    private func setupUI() {
        view.backgroundColor = DS.Colors.background
        title = descriptor.title

        view.addSubview(scrollView)
        view.addSubview(stateView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadScreen() {
        stateView.isHidden = false
        stateView.render(.loading(title: "Загружаем BDUI", subtitle: "Получаем JSON и строим экран"))
        removeRenderedSubviews()

        Task { [weak self] in
            guard let self else { return }
            do {
                let node = try await service.fetchScreen(path: descriptor.path)
                let renderedView = mapper.makeView(from: node, actionHandler: self)
                await MainActor.run {
                    self.renderScreen(renderedView)
                }
            } catch {
                await MainActor.run {
                    self.stateView.isHidden = false
                    self.stateView.render(.error(
                        title: "Не удалось загрузить BDUI",
                        subtitle: error.localizedDescription,
                        actionTitle: "Повторить"
                    ))
                }
            }
        }
    }

    private func renderScreen(_ renderedView: UIView) {
        removeRenderedSubviews()
        stateView.isHidden = true
        contentView.addSubview(renderedView)

        NSLayoutConstraint.activate([
            renderedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DS.Spacing.large),
            renderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DS.Spacing.large),
            renderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DS.Spacing.large),
            renderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DS.Spacing.large),
        ])
    }

    private func removeRenderedSubviews() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func handle(action: BDUIAction) {
        switch action {
        case .print(let message):
            print("BDUI action:", message)
        case .reload:
            loadScreen()
        case .navigateBack:
            navigationController?.popViewController(animated: true)
        }
    }
}
