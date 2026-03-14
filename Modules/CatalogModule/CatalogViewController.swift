
import UIKit

class CatalogViewController: UIViewController, CatalogView {
    var presenter: CatalogPresenterInput?

    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            let label = UILabel()
            label.text = "Они скоро появятся..."
            label.textAlignment = .center
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }

    // Пример: выбор плейлиста
    func didSelectPlaylist(_ playlistId: String) {
        presenter?.didSelectPlaylist(playlistId)
    }

    // Пример: выход
    func didTapLogout() {
        presenter?.didTapLogout()
    }

    func render(_ state: CatalogViewState) {
        switch state {
        case .loading:
            print("Loading...")
            // Показать индикатор загрузки
        case .content(_):
            // Обновить таблицу с секциями
            print("Loading...")
        case .empty:
            // Показать "ничего нет"
            print("Loading...")
        case .error(_):
            // Показать alert с message
            print("Loading...")
        }
    }
}
