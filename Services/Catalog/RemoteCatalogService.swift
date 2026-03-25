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
            URLQueryItem(name: "per_page", value: "30"),
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
        guard let title = dto.title, !title.isEmpty else { return nil }

        let id = String(dto.id)
        let subtitle: String?
        if let country = dto.country, !country.isEmpty, let kind = dto.type, !kind.isEmpty {
            subtitle = "\(country) · \(kind)"
        } else {
            subtitle = dto.country ?? dto.type
        }

        let rightText: String? = dto.year.flatMap { $0.isEmpty ? nil : $0 }

        let imageURLString = dto.coverImage ?? dto.thumb
        let imageURL = imageURLString.flatMap(URL.init(string:))

        return CatalogListItem(
            id: id,
            title: title,
            subtitle: subtitle,
            detailLine: rightText,
            artworkURL: imageURL
        )
    }
}
