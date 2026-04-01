import Foundation

final class RemoteCatalogService: CatalogService, @unchecked Sendable {
    private let networkClient: NetworkClient
    private let searchTerm: String

    init(networkClient: NetworkClient, searchTerm: String = "rock") {
        self.networkClient = networkClient
        self.searchTerm = searchTerm
    }

    func fetchCatalog(for userId: String) async throws -> [CatalogListItem] {
        _ = userId
        guard var components = URLComponents(string: "https://api.discogs.com/database/search") else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: searchTerm),
            URLQueryItem(name: "type", value: "release"),
            URLQueryItem(name: "per_page", value: "100"),
        ]
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        do {
            let response: DiscogsSearchResponseDTO = try await networkClient.get(url)
            let items = response.results.compactMap(Self.mapDTOToDomain)
            if items.isEmpty, let bundled = Self.loadFallbackFromBundle() {
                return bundled
            }
            return items
        } catch {
             if let bundled = Self.loadFallbackFromBundle() {
                 return bundled
             }
            throw error
        }
    }

    private static func loadFallbackFromBundle() -> [CatalogListItem]? {
        guard let fileURL = Bundle.main.url(forResource: "catalog_fallback", withExtension: "json"),
              let data = try? Data(contentsOf: fileURL)
        else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        guard let dto = try? decoder.decode(DiscogsSearchResponseDTO.self, from: data) else {
            return nil
        }
        let items = dto.results.compactMap(mapDTOToDomain)
        return items.isEmpty ? nil : items
    }

    private static func mapDTOToDomain(_ dto: DiscogsSearchResultDTO) -> CatalogListItem? {
        guard let rawTitle = dto.title, !rawTitle.isEmpty else { return nil }

        let parsed = splitDiscogsTitle(rawTitle)

        let id = String(dto.id)
        let subtitle: String?
        if let artist = parsed.artist {
            subtitle = artist
        } else if let country = dto.country, !country.isEmpty, let kind = dto.type, !kind.isEmpty {
            subtitle = "\(country) · \(kind)"
        } else {
            subtitle = dto.country ?? dto.type
        }

        let rightText: String? = dto.year.flatMap { $0.isEmpty ? nil : $0 }

        return CatalogListItem(
            id: id,
            title: parsed.title,
            subtitle: subtitle,
            detailLine: rightText,
            artworkURL: nil
        )
    }

    private static func splitDiscogsTitle(_ rawTitle: String) -> (artist: String?, title: String) {
        let parts = rawTitle
            .split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard parts.count == 2 else {
            return (artist: nil, title: rawTitle)
        }

        let artist = parts[0].isEmpty ? nil : parts[0]
        let title = parts[1].isEmpty ? rawTitle : parts[1]
        return (artist: artist, title: title)
    }
}
