
import UIKit

class PlaylistDetailViewController: UIViewController, PlaylistDetailView {
    var presenter: PlaylistDetailPresenterInput?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Здесь будет UI
    }

    // Пример: выбор трека
    func didTapTrack(at index: Int) {
        presenter?.didTapTrack(at: index)
    }

    // Пример: лайк/дизлайк
    func didToggleFavorite(for trackId: String) {
        presenter?.didToggleFavorite(for: trackId)
    }

    // Пример: возврат
    func didTapBack() {
        presenter?.didTapBack()
    }

    func render(_ state: PlaylistDetailViewState) {
        switch state {
        case .loading:
            print("hello...")
            // Показать индикатор загрузки
        case .content(let tracks, let isPlaying, let currentIndex):
            print("hello...")
            // Обновить таблицу с треками
            // Подсветить текущий трек, если isPlaying
        case .empty:
            print("hello...")
            // Показать "ничего нет"
        case .error(let message):
            print("hello...")
            // Показать alert с message
        }
    }
}
