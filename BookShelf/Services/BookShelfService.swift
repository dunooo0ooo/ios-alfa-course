import Foundation

public final class BookShelfService: BookShelfProtocol {
    private var books: [UUID: Book] = [:]
    private let validator: BookValidator

    public init(validator: BookValidator = BookValidator()) {
        self.validator = validator
    }

    public func add(title: String, author: String, year: Int) throws -> Book {
        try validator.validate(title: title, author: author, year: year)
        let book = Book(title: title, author: author, year: year)
        books[book.id] = book
        return book
    }

    public func list() -> [Book] {
        books.values.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    public func get(id: UUID) throws -> Book {
        guard let book = books[id] else { throw BookShelfError.notFound(id: id) }
        return book
    }

    public func delete(id: UUID) throws {
        guard books.removeValue(forKey: id) != nil else { throw BookShelfError.notFound(id: id) }
    }

    public func edit(id: UUID, newTitle: String?, newAuthor: String?, newYear: Int?) throws -> Book {
        guard var book = books[id] else { throw BookShelfError.notFound(id: id) }

        let title = newTitle ?? book.title
        let author = newAuthor ?? book.author
        let year = newYear ?? book.year

        try validator.validate(title: title, author: author, year: year)

        book.title = title
        book.author = author
        book.year = year

        books[id] = book
        return book
    }
}
