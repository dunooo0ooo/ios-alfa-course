import UIKit

protocol ImageLoading: AnyObject {
    func loadImage(from url: URL?, bindTo token: AnyObject, completion: @escaping (UIImage?) -> Void)
    func cancelLoad(for token: AnyObject)
}
