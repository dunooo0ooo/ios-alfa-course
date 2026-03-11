
import UIKit

class CatalogViewController: UIViewController, CatalogView {
    var presenter: CatalogPresenterInput?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Здесь будет UI
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
