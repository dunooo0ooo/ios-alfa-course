import Foundation

public final class BookShelfService: BookShelfProtocol {
    private var books: [String: Book] = [:]
    private let validator = BookValidator()

    public init() {}

    public func add(_ book: Book) throws {
        try validator.validate(book)
        if books[book.id] != nil { throw BookShelfError.duplicateId(book.id) }
        books[book.id] = book
    }

    public func delete(id: String) throws {
        guard books.removeValue(forKey: id) != nil else { throw BookShelfError.notFound(id: id) }
    }

    public func list() -> [Book] {
        books.values.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    public func search(_ query: SearchQuery) -> [Book] {
        let all = list()
        switch query {
        case .title(let s):
            let q = norm(s)
            return all.filter { norm($0.title).contains(q) }
        case .author(let s):
            let q = norm(s)
            return all.filter { norm($0.author).contains(q) }
        case .genre(let g):
            return all.filter { $0.genre == g }
        case .tag(let t):
            let q = norm(t)
            return all.filter { $0.tags.map(norm).contains(q) }
        case .year(let y):
            return all.filter { $0.publicationYear == y }
        }
    }


    public func edit(id: String,
                     newTitle: String?,
                     newAuthor: String?,
                     newPublicationYear: Int?,
                     newGenre: Genre?,
                     newTags: [String]?) throws {
        guard var b = books[id] else { throw BookShelfError.notFound(id: id) }

        if let v = newTitle { b.title = v }
        if let v = newAuthor { b.author = v }
        if let v = newPublicationYear { b.publicationYear = v }
        if let v = newGenre { b.genre = v }
        if let v = newTags { b.tags = v }

        try validator.validate(b)
        books[id] = b
    }

    private func norm(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
