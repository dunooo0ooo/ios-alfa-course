import UIKit

final class BDUIScreenViewController: UIViewController, BDUIScreenView, BDUIActionHandling {
    var presenter: BDUIScreenPresenterInput?

    private let mapper: BDUIViewMapping

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
            self?.presenter?.didTapRetry()
        }
        return view
    }()

    init(
        mapper: BDUIViewMapping = BDUIViewMapper()
    ) {
        self.mapper = mapper
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.didLoad()
    }

    private func setupUI() {
        view.backgroundColor = DS.Colors.background
        title = presenter?.title

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

    func render(_ state: BDUIScreenViewState) {
        switch state {
        case .loading(let title, let subtitle):
            removeRenderedSubviews()
            stateView.isHidden = false
            stateView.render(.loading(title: title, subtitle: subtitle))
        case .content(let node):
            let renderedView = mapper.makeView(from: node, actionHandler: self)
            renderScreen(renderedView)
        case .error(let title, let subtitle, let actionTitle):
            removeRenderedSubviews()
            stateView.isHidden = false
            stateView.render(.error(title: title, subtitle: subtitle, actionTitle: actionTitle))
        }
    }

    func handle(action: BDUIAction) {
        presenter?.didTrigger(action: action)
    }
}
