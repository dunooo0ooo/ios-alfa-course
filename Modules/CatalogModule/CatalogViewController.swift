
import UIKit

class CatalogViewController: UIViewController, CatalogView {
    var interactor: CatalogInteractorInput?
    var catalogUserId: String?
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Они скоро появятся..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        if let userId = catalogUserId {
            interactor?.loadCatalog(for: userId)
        }
    }

    func didSelectPlaylist(_ playlistId: String) {
        interactor?.didSelectPlaylist(playlistId)
    }

    func didTapLogout() {
        interactor?.didTapLogout()
    }

    func render(_ state: CatalogViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            print("Catalog: loading…")
        case .content(let items):
            print("Catalog: \(items.count) элементов")
            for item in items.prefix(5) {
                print("  • \(item.title) — \(item.subtitle ?? "")")
            }
        case .empty:
            print("Catalog: пусто")
        case .error(let message):
            print("Catalog: error — \(message)")
        }
    }
}
