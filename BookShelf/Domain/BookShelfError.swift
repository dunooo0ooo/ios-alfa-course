import Foundation

public enum BookShelfError: Error, CustomStringConvertible, Equatable {
    case emptyTitle
    case emptyAuthor
    case invalidYear(min: Int, max: Int)

    case notFound(id: UUID)

    case invalidUUID(String)
    case invalidYearFormat(String)

    public var description: String {
        switch self {
        case .emptyTitle:
            return "Название не должно быть пустым."
        case .emptyAuthor:
            return "Автор не должен быть пустым."
        case let .invalidYear(min, max):
            return "Год должен быть в диапазоне \(min)...\(max)."
        case let .notFound(id):
            return "Книга не найдена: \(id.uuidString)"
        case let .invalidUUID(s):
            return "Неверный UUID: \(s)"
        case let .invalidYearFormat(s):
            return "Неверный формат года: \(s)"
        }
    }
}
