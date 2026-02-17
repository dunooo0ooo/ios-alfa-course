import Foundation

public struct BookValidator {
    public let minYear: Int
    public let maxYear: Int

    public init(minYear: Int = 1450,
                maxYear: Int = Calendar.current.component(.year, from: Date())) {
        self.minYear = minYear
        self.maxYear = maxYear
    }

    public func validate(title: String, author: String, year: Int) throws {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw BookShelfError.emptyTitle
        }
        if author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw BookShelfError.emptyAuthor
        }
        if year < minYear || year > maxYear {
            throw BookShelfError.invalidYear(min: minYear, max: maxYear)
        }
    }
}
