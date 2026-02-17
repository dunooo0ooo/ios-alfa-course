import Foundation

public final class ConsoleApp {
    private let shelf: BookShelfProtocol

    public init(shelf: BookShelfProtocol) {
        self.shelf = shelf
    }

    public func run() {
        print("""
        === BookShelf CLI ===
        help
        add <title> | <author> | <year>
        list
        get <uuid>
        edit <uuid> [title="..."] [author="..."] [year=1234]
        del <uuid>
        exit
        """)

        while true {
            print("\n> ", terminator: "")
            guard let line = readLine() else {
                print("EOF. Exit.")
                return
            }

            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            if trimmed.lowercased() == "exit" { print("Bye."); return }

            do {
                try handle(trimmed)
            } catch let e as BookShelfError {
                print("Error: \(e.description)")
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }

    private func handle(_ line: String) throws {
        let parts = line.split(separator: " ", maxSplits: 1).map(String.init)
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
        case "edit":
            try cmdEdit(tail)
        case "del":
            try cmdDel(tail)
        default:
            print("Unknown command: \(cmd). Type 'help'.")
        }
    }

    private func printHelp() {
        print("""
        Commands:
          help
          add <title> | <author> | <year>
          list
          get <uuid>
          edit <uuid> [title="..."] [author="..."] [year=1234]
          del <uuid>
          exit
        """)
    }

    private func cmdAdd(_ tail: String) throws {
        let items = tail.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard items.count == 3 else {
            print("Usage: add <title> | <author> | <year>")
            return
        }

        guard let year = Int(items[2]) else {
            throw BookShelfError.invalidYearFormat(items[2])
        }

        let book = try shelf.add(title: items[0], author: items[1], year: year)
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
        let s = tail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let id = UUID(uuidString: s) else { throw BookShelfError.invalidUUID(s) }
        let book = try shelf.get(id: id)
        print(format(book))
    }

    private func cmdDel(_ tail: String) throws {
        let s = tail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let id = UUID(uuidString: s) else { throw BookShelfError.invalidUUID(s) }
        try shelf.delete(id: id)
        print("Deleted: \(id.uuidString)")
    }

    private func cmdEdit(_ tail: String) throws {
        let tokens = tokenizeKeepingQuotes(tail)
        guard !tokens.isEmpty else {
            print("Usage: edit <uuid> [title=\"...\"] [author=\"...\"] [year=1234]")
            return
        }

        let idStr = tokens[0]
        guard let id = UUID(uuidString: idStr) else { throw BookShelfError.invalidUUID(idStr) }

        var newTitle: String?
        var newAuthor: String?
        var newYear: Int?

        for t in tokens.dropFirst() {
            if let v = parseKV(t, key: "title") { newTitle = v; continue }
            if let v = parseKV(t, key: "author") { newAuthor = v; continue }
            if let v = parseKV(t, key: "year") {
                guard let y = Int(v) else { throw BookShelfError.invalidYearFormat(v) }
                newYear = y
                continue
            }
            print("Warning: ignored token '\(t)'")
        }

        if newTitle == nil && newAuthor == nil && newYear == nil {
            print("Nothing to edit. Provide at least one field.")
            return
        }

        let updated = try shelf.edit(id: id, newTitle: newTitle, newAuthor: newAuthor, newYear: newYear)
        print("Updated: \(format(updated))")
    }


    private func format(_ b: Book) -> String {
        "[\(b.id.uuidString)] \"\(b.title)\" — \(b.author), \(b.year)"
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
