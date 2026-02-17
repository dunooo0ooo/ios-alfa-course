import Foundation

public struct Book: Codable, Equatable, Identifiable {
    public let id: UUID
    public var title: String
    public var author: String
    public var year: Int

    public init(id: UUID = UUID(), title: String, author: String, year: Int) {
        self.id = id
        self.title = title
        self.author = author
        self.year = year
    }
}
