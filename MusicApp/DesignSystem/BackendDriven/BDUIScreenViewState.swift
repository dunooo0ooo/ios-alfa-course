enum BDUIScreenViewState: Equatable {
    case loading(title: String, subtitle: String)
    case content(BDUIViewNode)
    case error(title: String, subtitle: String, actionTitle: String)
}
