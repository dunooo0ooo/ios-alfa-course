import Foundation

public struct BookValidator {
    public let minYear: Int
    public let maxYear: Int

    public init(minYear: Int = 1450,
                maxYear: Int = Calendar.current.component(.year, from: Date())) {
        self.minYear = minYear
        self.maxYear = maxYear
    }

    public func validate(title: String, author: String, year: Int?) throws {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw BookShelfError.emptyTitle
        }
        if author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw BookShelfError.emptyAuthor
        }
        if let y = year, (y < minYear || y > maxYear) {
            throw BookShelfError.invalidYear(min: minYear, max: maxYear)
        }
    }

    public func validate(_ book: Book) throws {
        try validate(title: book.title, author: book.author, year: book.publicationYear)
    }
}
