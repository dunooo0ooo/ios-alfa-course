import Foundation

public struct Book: Codable, Equatable, Identifiable {
    public let id: String
    public var title: String
    public var author: String
    public var publicationYear: Int
    public var genre: Genre
    public var tags: [String]

    public init(
        id: String = UUID().uuidString,
        title: String,
        author: String,
        publicationYear: Int,
        genre: Genre,
        tags: [String]
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publicationYear = publicationYear
        self.genre = genre
        self.tags = tags
    }
}
