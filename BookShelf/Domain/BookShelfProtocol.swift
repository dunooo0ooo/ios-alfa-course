import Foundation

public protocol BookShelfProtocol {
    func add(_ book: Book) throws
    func delete(id: String) throws
    func list() -> [Book]
    func search(_ query: SearchQuery) -> [Book]
    
    func edit(id: String,
              newTitle: String?,
              newAuthor: String?,
              newPublicationYear: Int?,
              newGenre: Genre?,
              newTags: [String]?) throws
}
