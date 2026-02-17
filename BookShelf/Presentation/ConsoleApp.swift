import Foundation

public final class ConsoleApp {
    private let shelf: BookShelfProtocol

    public init(shelf: BookShelfProtocol) {
        self.shelf = shelf
    }

    public func run() {
        printHelp()

        while true {
            print("\n> ", terminator: "")
            guard let line = readLine() else {
                print("EOF. Exit.")
                return
            }

            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            if trimmed.lowercased() == "exit" {
                print("Bye.")
                return
            }

            do {
                try handle(trimmed)
            } catch let e as BookShelfError {
                print("Error: \(e.description)")
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }

    private func printHelp() {
        print("""
        === BookShelf CLI ===
        help
        add <title> | <author> | <year> | <genre> | <tags-comma-separated>
        list
        get <id>
        search (title|author|genre|tag|year) <query>
        edit <id> [title="..."] [author="..."] [year=1234] [genre=...] [tags="t1,t2"]
        del <id>
        exit

        Notes:
          - add uses '|' separators.
          - quoted values keep spaces: title="Clean Code"
          - genre must be one of: \(Genre.allCases.map{$0.rawValue}.joined(separator: ", "))
        """)
    }

    private func handle(_ line: String) throws {
        let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        let cmd = parts[0].lowercased()
        let tail = parts.count > 1 ? parts[1] : ""

        switch cmd {
        case "help":
            printHelp()
        case "add":
            try cmdAdd(tail)
        case "list":
            cmdList()
        case "get":
            try cmdGet(tail)
        case "search":
            try cmdSearch(tail)
        case "edit":
            try cmdEdit(tail)
        case "del":
            try cmdDel(tail)
        default:
            print("Unknown command '\(cmd)'. Type 'help'.")
        }
    }

    private func cmdAdd(_ tail: String) throws {
        let items = tail.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard items.count == 5 else {
            print("Usage: add <title> | <author> | <year> | <genre> | <tags-comma-separated>")
            return
        }

        let title = items[0]
        let author = items[1]
        let yearStr = items[2]
        let genreStr = items[3]
        let tagsStr = items[4]

        guard let year = Int(yearStr) else { throw BookShelfError.invalidYearFormat(yearStr) }

        guard let genre = Genre(rawValue: genreStr) else {
            print("Error: invalid genre '\(genreStr)'. Use one of: \(Genre.allCases.map{$0.rawValue}.joined(separator: ", "))")
            return
        }

        let tags = parseTags(tagsStr)

        let book = Book(title: title, author: author, publicationYear: year, genre: genre, tags: tags)
        try shelf.add(book)

        print("Added: \(format(book))")
    }

    private func cmdList() {
        let books = shelf.list()
        if books.isEmpty {
            print("(empty)")
            return
        }
        print("Books (\(books.count)):")
        for b in books {
            print("  \(format(b))")
        }
    }

    private func cmdGet(_ tail: String) throws {
        let id = tail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else {
            print("Usage: get <id>")
            return
        }

        guard let book = shelf.list().first(where: { $0.id == id }) else {
            throw BookShelfError.notFound(id: id)
        }
        print(format(book))
    }

    private func cmdSearch(_ tail: String) throws {
        let parts = tail.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        guard parts.count == 2 else {
            print("Usage: search (title|author|genre|tag|year) <query>")
            return
        }

        let mode = parts[0].lowercased()
        let q = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

        let query: SearchQuery
        switch mode {
        case "title":
            query = .title(q)
        case "author":
            query = .author(q)
        case "tag":
            query = .tag(q)
        case "year":
            guard let y = Int(q) else { throw BookShelfError.invalidYearFormat(q) }
            query = .year(y)
        case "genre":
            guard let g = Genre(rawValue: q) else {
                print("Error: invalid genre '\(q)'. Use one of: \(Genre.allCases.map{$0.rawValue}.joined(separator: ", "))")
                return
            }
            query = .genre(g)
        default:
            print("Usage: search (title|author|genre|tag|year) <query>")
            return
        }

        let result = shelf.search(query)
        if result.isEmpty {
            print("(no matches)")
            return
        }

        print("Found (\(result.count)):")
        for b in result {
            print("  \(format(b))")
        }
    }

    private func cmdEdit(_ tail: String) throws {
        let tokens = tokenizeKeepingQuotes(tail)
        guard !tokens.isEmpty else {
            print("Usage: edit <id> [title=\"...\"] [author=\"...\"] [year=1234] [genre=...] [tags=\"t1,t2\"]")
            return
        }

        let id = tokens[0]
        guard !id.isEmpty else { print("Error: id is empty"); return }

        var newTitle: String?
        var newAuthor: String?
        var newYear: Int? = nil
        var newGenre: Genre?
        var newTags: [String]?

        for t in tokens.dropFirst() {
            if let v = parseKV(t, key: "title") { newTitle = v; continue }
            if let v = parseKV(t, key: "author") { newAuthor = v; continue }

            if let v = parseKV(t, key: "year") {
                guard let y = Int(v) else { throw BookShelfError.invalidYearFormat(v) }
                newYear = y
                continue
            }

            if let v = parseKV(t, key: "genre") {
                guard let g = Genre(rawValue: v) else {
                    print("Error: invalid genre '\(v)'. Use one of: \(Genre.allCases.map{$0.rawValue}.joined(separator: ", "))")
                    return
                }
                newGenre = g
                continue
            }

            if let v = parseKV(t, key: "tags") {
                newTags = parseTags(v)
                continue
            }

            print("Warning: ignored token '\(t)'")
        }

        if newTitle == nil, newAuthor == nil, newYear == nil, newGenre == nil, newTags == nil {
            print("Nothing to edit. Provide at least one field.")
            return
        }

        try shelf.edit(
            id: id,
            newTitle: newTitle,
            newAuthor: newAuthor,
            newPublicationYear: newYear,
            newGenre: newGenre,
            newTags: newTags
        )

        print("Updated.")
    }

    private func cmdDel(_ tail: String) throws {
        let id = tail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else {
            print("Usage: del <id>")
            return
        }
        try shelf.delete(id: id)
        print("Deleted: \(id)")
    }

    private func parseTags(_ s: String) -> [String] {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        return trimmed
            .split(separator: ",", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func format(_ b: Book) -> String {
        let tags = b.tags.isEmpty ? "-" : b.tags.joined(separator: ",")
        return "[\(b.id)] \"\(b.title)\" — \(b.author), year=\(b.publicationYear), genre=\(b.genre.rawValue), tags=\(tags)"
    }

    private func tokenizeKeepingQuotes(_ s: String) -> [String] {
        var res: [String] = []
        var cur = ""
        var inQuotes = false

        for ch in s {
            if ch == "\"" { inQuotes.toggle(); continue }
            if ch == " " && !inQuotes {
                if !cur.isEmpty { res.append(cur); cur = "" }
            } else {
                cur.append(ch)
            }
        }
        if !cur.isEmpty { res.append(cur) }

        return res.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                  .filter { !$0.isEmpty }
    }

    private func parseKV(_ token: String, key: String) -> String? {
        let prefix = key + "="
        guard token.hasPrefix(prefix) else { return nil }
        return String(token.dropFirst(prefix.count))
    }
}
