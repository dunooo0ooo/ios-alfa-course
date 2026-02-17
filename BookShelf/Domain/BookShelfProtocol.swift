import Foundation

public protocol BookShelfProtocol {
    func add(title: String, author: String, year: Int) throws -> Book
    func list() -> [Book]
    func get(id: UUID) throws -> Book
    func delete(id: UUID) throws
    func edit(id: UUID, newTitle: String?, newAuthor: String?, newYear: Int?) throws -> Book
}
