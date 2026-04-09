
import UIKit

final class CatalogViewController: UIViewController, CatalogView, UISearchBarDelegate, CatalogListManagerDelegate {
    var interactor: CatalogInteractorInput?
    var catalogUserId: String?
    var imageLoader: ImageLoading = ImageCacheService()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Поиск по списку"
        bar.delegate = self
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.accessibilityIdentifier = "catalogSearchBar"
        return bar
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tableFooterView = UIView()
        tv.accessibilityIdentifier = "catalogTableView"
        return tv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        return control
    }()

    private lazy var listContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var stateOverlay: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.isHidden = true
        return v
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        return v
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Повторить", for: .normal)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    private lazy var messageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()

    private var listManager: CatalogListManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

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
        listContainer.addSubview(stateOverlay)
        stateOverlay.addSubview(loadingIndicator)
        stateOverlay.addSubview(messageStack)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            listContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            listContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: listContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: listContainer.bottomAnchor),

            stateOverlay.topAnchor.constraint(equalTo: listContainer.topAnchor),
            stateOverlay.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor),
            stateOverlay.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor),
            stateOverlay.bottomAnchor.constraint(equalTo: listContainer.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: stateOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: stateOverlay.centerYAnchor),

            messageStack.centerXAnchor.constraint(equalTo: stateOverlay.centerXAnchor),
            messageStack.centerYAnchor.constraint(equalTo: stateOverlay.centerYAnchor),
            messageStack.leadingAnchor.constraint(greaterThanOrEqualTo: stateOverlay.leadingAnchor, constant: 24),
            messageStack.trailingAnchor.constraint(lessThanOrEqualTo: stateOverlay.trailingAnchor, constant: -24),
        ])

        listManager = CatalogListManager(tableView: tableView, imageLoader: imageLoader)
        listManager.delegate = self

        if let userId = catalogUserId {
            interactor?.loadCatalog(for: userId, isRefresh: false)
        }
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

    func catalogListManagerDidSelectItem(id: String) {
        interactor?.didSelectPlaylist(id)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor?.searchQueryDidChange(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func didSelectPlaylist(_ playlistId: String) {
        interactor?.didSelectPlaylist(playlistId)
    }

    func didTapLogout() {
        interactor?.didTapLogout()
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
            stateOverlay.isHidden = false
            messageStack.isHidden = true
            loadingIndicator.startAnimating()
            tableView.isHidden = true
        case .content(let items):
            stateOverlay.isHidden = true
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            listManager.setItems(items)
        case .empty(let message):
            stateOverlay.isHidden = false
            loadingIndicator.stopAnimating()
            messageLabel.text = message
            retryButton.isHidden = true
            messageStack.isHidden = false
            tableView.isHidden = true
            listManager.setItems([])
        case .error(let message):
            stateOverlay.isHidden = false
            loadingIndicator.stopAnimating()
            messageLabel.text = message
            retryButton.isHidden = false
            messageStack.isHidden = false
            tableView.isHidden = true
            listManager.setItems([])
        }
    }
}
