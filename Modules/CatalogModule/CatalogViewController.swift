import UIKit

final class CatalogViewController: UIViewController, CatalogView, UISearchBarDelegate, BDUIActionHandling {
    var interactor: CatalogInteractorInput?
    var catalogUserId: String?
    var imageLoader: ImageLoading = ImageCacheService()
    private lazy var mapper: BDUIViewMapping = BDUIViewMapper(imageLoader: imageLoader)

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Поиск по списку"
        bar.delegate = self
        bar.searchBarStyle = .minimal
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.accessibilityIdentifier = "catalogSearchBar"
        if #available(iOS 13.0, *) {
            let textField = bar.searchTextField
            textField.backgroundColor = DS.Colors.surfaceElevated
            textField.textColor = DS.Colors.textPrimary
            textField.layer.cornerRadius = DS.Spacing.cornerRadius
            textField.clipsToBounds = true
        }
        return bar
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.accessibilityIdentifier = "catalogScrollView"
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = DS.Colors.primary
        control.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        return control
    }()

    private lazy var stateView: DSStateView = {
        let view = DSStateView()
        view.isHidden = true
        view.actionHandler = { [weak self] in
            self?.retryTapped()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if let userId = catalogUserId {
            interactor?.loadCatalog(for: userId, isRefresh: false)
        }
    }

    private func setupUI() {
        view.backgroundColor = DS.Colors.background
        title = "Подборка треков"

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = DS.Colors.primary
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "BDUI",
            style: .plain,
            target: self,
            action: #selector(bduiTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )

        scrollView.refreshControl = refreshControl

        view.addSubview(searchBar)
        view.addSubview(scrollView)
        view.addSubview(stateView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DS.Spacing.small),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.Spacing.small),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.Spacing.small),

            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: DS.Spacing.small),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stateView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func logoutTapped() {
        interactor?.didTapLogout()
    }

    @objc private func bduiTapped() {
        interactor?.didTapOpenBDUIDemo()
    }

    @objc private func retryTapped() {
        interactor?.retryLoadCatalog()
    }

    @objc private func refreshPulled() {
        guard let userId = catalogUserId else {
            refreshControl.endRefreshing()
            return
        }
        interactor?.loadCatalog(for: userId, isRefresh: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor?.searchQueryDidChange(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func setRefreshing(_ active: Bool) {
        if active {
            refreshControl.beginRefreshing()
        } else if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func handle(action: BDUIAction) {
        switch action {
        case .selectTrack(let id, let title, let subtitle):
            interactor?.didSelectTrack(id: id, title: title, subtitle: subtitle)
        case .reload:
            retryTapped()
        case .navigateBack:
            navigationController?.popViewController(animated: true)
        case .print(let message):
            print("BDUI action:", message)
        }
    }

    func render(_ state: CatalogViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            removeRenderedSubviews()
            stateView.isHidden = false
            stateView.render(.loading(title: "Загружаем треки", subtitle: "Подождите пару секунд"))
            scrollView.isHidden = true
        case .content(let node):
            renderNode(node)
            stateView.isHidden = true
            scrollView.isHidden = false
        case .empty(let message):
            removeRenderedSubviews()
            stateView.isHidden = false
            stateView.render(.empty(title: "Список пуст", subtitle: message))
            scrollView.isHidden = true
        case .error(let message):
            removeRenderedSubviews()
            stateView.isHidden = false
            stateView.render(.error(title: "Не удалось загрузить список", subtitle: message, actionTitle: "Повторить"))
            scrollView.isHidden = true
        }
    }

    private func renderNode(_ node: BDUIViewNode) {
        removeRenderedSubviews()
        let renderedView = mapper.makeView(from: node, actionHandler: self)
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
}
