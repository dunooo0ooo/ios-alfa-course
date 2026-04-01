import UIKit

protocol CatalogListManagerDelegate: AnyObject {
    func catalogListManagerDidSelectItem(id: String)
}

final class CatalogListManager: NSObject {
    weak var delegate: CatalogListManagerDelegate?

    private weak var tableView: UITableView?
    private let imageLoader: ImageLoading
    private var items: [PlaylistCellViewModel] = []

    init(tableView: UITableView, imageLoader: ImageLoading) {
        self.tableView = tableView
        self.imageLoader = imageLoader
        super.init()
        tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.keyboardDismissMode = .onDrag
    }

    func setItems(_ items: [PlaylistCellViewModel]) {
        self.items = items
        tableView?.reloadData()
    }

    var currentItems: [PlaylistCellViewModel] { items }
}

extension CatalogListManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaylistTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? PlaylistTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row], imageLoader: imageLoader)
        return cell
    }
}

extension CatalogListManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let id = items[indexPath.row].id
        delegate?.catalogListManagerDidSelectItem(id: id)
    }
}
