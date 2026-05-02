import UIKit

final class CatalogViewController: UIViewController, CatalogView, UISearchBarDelegate, CatalogListManagerDelegate {
    var interactor: CatalogInteractorInput?
    var catalogUserId: String?
    var imageLoader: ImageLoading = ImageCacheService()
    private lazy var listManager = CatalogListManager(tableView: tableView, imageLoader: imageLoader)

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
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.accessibilityIdentifier = "catalogTableView"
        return table
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
        listManager.delegate = self

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

        tableView.refreshControl = refreshControl

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(stateView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DS.Spacing.small),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.Spacing.small),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.Spacing.small),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: DS.Spacing.small),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stateView.topAnchor.constraint(equalTo: tableView.topAnchor),
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

    func catalogListManagerDidSelectItem(_ item: PlaylistCellViewModel) {
        interactor?.didSelectTrack(id: item.id, title: item.title, subtitle: item.subtitle)
    }

    func render(_ state: CatalogViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            stateView.isHidden = false
            stateView.render(.loading(title: "Загружаем треки", subtitle: "Подождите пару секунд"))
            tableView.isHidden = true
        case .content(let items):
            listManager.setItems(items)
            stateView.isHidden = true
            tableView.isHidden = false
        case .empty(let message):
            stateView.isHidden = false
            stateView.render(.empty(title: "Список пуст", subtitle: message))
            tableView.isHidden = true
        case .error(let message):
            stateView.isHidden = false
            stateView.render(.error(title: "Не удалось загрузить список", subtitle: message, actionTitle: "Повторить"))
            tableView.isHidden = true
        }
    }
}
