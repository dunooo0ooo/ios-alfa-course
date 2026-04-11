import UIKit

final class PlaylistDetailViewController: UIViewController, PlaylistDetailView {
    var presenter: PlaylistDetailPresenterInput?
    var playlistId: String?
    var trackTitle: String?
    var trackSubtitle: String?

    private var tracks: [Track] = []
    private var currentIndex: Int = 0

    private lazy var artworkView: UIImageView = {
        let view = UIImageView(image: DS.Icons.playlist)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = DS.Colors.primary
        view.backgroundColor = DS.Colors.surface
        view.layer.cornerRadius = DS.Spacing.cornerRadiusLarge
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        view.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .medium)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(.screenTitle)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(.body)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var stateView: DSStateView = {
        let view = DSStateView()
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.didLoad(playlistId: playlistId ?? "")
    }

    private func setupUI() {
        view.backgroundColor = DS.Colors.background
        title = "Трек"

        view.addSubview(artworkView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stateView)

        NSLayoutConstraint.activate([
            artworkView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -90),
            artworkView.widthAnchor.constraint(equalToConstant: DS.Spacing.heroArtworkSize),
            artworkView.heightAnchor.constraint(equalToConstant: DS.Spacing.heroArtworkSize),

            titleLabel.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: DS.Spacing.xLarge),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.Spacing.xLarge),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.Spacing.xLarge),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DS.Spacing.small),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func render(_ state: PlaylistDetailViewState) {
        switch state {
        case .loading:
            stateView.isHidden = false
            stateView.actionHandler = nil
            stateView.render(.loading(title: "Загружаем трек", subtitle: "Подготавливаем экран"))
            artworkView.isHidden = true
            titleLabel.isHidden = true
            subtitleLabel.isHidden = true
        case .content(let tracks, _, let currentIndex):
            self.tracks = tracks
            self.currentIndex = min(max(currentIndex ?? 0, 0), max(tracks.count - 1, 0))
            let currentTrack = tracks[self.currentIndex]
            titleLabel.text = trackTitle ?? currentTrack.title
            subtitleLabel.text = trackSubtitle ?? currentTrack.artist
            stateView.isHidden = true
            artworkView.isHidden = false
            titleLabel.isHidden = false
            subtitleLabel.isHidden = false
        case .empty:
            stateView.isHidden = false
            stateView.actionHandler = nil
            stateView.render(.empty(title: "Трек не найден", subtitle: "Для этого элемента пока нет данных"))
            artworkView.isHidden = true
            titleLabel.isHidden = true
            subtitleLabel.isHidden = true
        case .error(let message):
            stateView.isHidden = false
            stateView.render(.error(title: "Не удалось открыть трек", subtitle: message, actionTitle: "Назад"))
            stateView.actionHandler = { [weak self] in
                self?.presenter?.didTapBack()
            }
            artworkView.isHidden = true
            titleLabel.isHidden = true
            subtitleLabel.isHidden = true
        }
    }
}
