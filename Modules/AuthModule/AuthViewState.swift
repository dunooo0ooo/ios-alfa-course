
enum AuthViewState: Equatable {
    case initial
    case loading
    case content(email: String)
    case error(message: String)
}
