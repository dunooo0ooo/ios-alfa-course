import UIKit

final class CatalogViewController: UIViewController, CatalogView, UISearchBarDelegate, CatalogListManagerDelegate {
    var interactor: CatalogInteractorInput?
    var catalogUserId: String?
    var imageLoader: ImageLoading = ImageCacheService()

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

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tableFooterView = UIView()
        tv.backgroundColor = .clear
        tv.separatorColor = DS.Colors.separator
        tv.accessibilityIdentifier = "catalogTableView"
        return tv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = DS.Colors.primary
        control.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        return control
    }()

    private lazy var listContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stateView: DSStateView = {
        let view = DSStateView()
        view.isHidden = true
        view.actionHandler = { [weak self] in
            self?.retryTapped()
        }
        return view
    }()

    private var listManager: CatalogListManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        listManager = CatalogListManager(tableView: tableView, imageLoader: imageLoader)
        listManager.delegate = self

        if let userId = catalogUserId {
            interactor?.loadCatalog(for: userId, isRefresh: false)
        }
    }

    private func setupUI() {
        view.backgroundColor = DS.Colors.background
        title = "Подборка плейлистов"

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = DS.Colors.primary
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )

        tableView.refreshControl = refreshControl

        view.addSubview(searchBar)
        view.addSubview(listContainer)
        listContainer.addSubview(tableView)
        listContainer.addSubview(stateView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DS.Spacing.small),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.Spacing.small),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.Spacing.small),

            listContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: DS.Spacing.small),
            listContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: listContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: listContainer.bottomAnchor),

            stateView.topAnchor.constraint(equalTo: listContainer.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: listContainer.bottomAnchor),
        ])
    }

    @objc private func logoutTapped() {
        interactor?.didTapLogout()
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

    func catalogListManagerDidSelectItem(_ item: PlaylistCellViewModel) {
        interactor?.didSelectTrack(id: item.id, title: item.title, subtitle: item.subtitle)
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

    func render(_ state: CatalogViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            stateView.isHidden = false
            stateView.render(.loading(title: "Загружаем плейлисты", subtitle: "Подождите пару секунд"))
            tableView.isHidden = true
        case .content(let items):
            stateView.isHidden = true
            tableView.isHidden = false
            listManager.setItems(items)
        case .empty(let message):
            stateView.isHidden = false
            stateView.render(.empty(title: "Список пуст", subtitle: message))
            tableView.isHidden = true
            listManager.setItems([])
        case .error(let message):
            stateView.isHidden = false
            stateView.render(.error(title: "Не удалось загрузить список", subtitle: message, actionTitle: "Повторить"))
            tableView.isHidden = true
            listManager.setItems([])
        }
    }
}
