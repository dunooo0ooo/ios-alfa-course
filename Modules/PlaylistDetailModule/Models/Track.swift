import Foundation

struct Track: Equatable {
    let id: String
    let title: String
    let artist: String
    let duration: TimeInterval
    let url: String
    var isFavorite: Bool
}
