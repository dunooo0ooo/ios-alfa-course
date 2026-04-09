
protocol CatalogView: AnyObject {
    func render(_ state: CatalogViewState)
    func setRefreshing(_ active: Bool)
}
