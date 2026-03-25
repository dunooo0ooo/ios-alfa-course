import Foundation

struct DiscogsSearchResponseDTO: Codable, Sendable {
    let results: [DiscogsSearchResultDTO]
}

struct DiscogsSearchResultDTO: Codable, Sendable {
    let id: Int
    let type: String?
    let title: String?
    let year: String?
    let country: String?
    let thumb: String?
    let coverImage: String?

    enum CodingKeys: String, CodingKey {
        case id, type, title, year, country, thumb
        case coverImage = "cover_image"
    }
}
