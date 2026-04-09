import UIKit

final class ImageCacheService: ImageLoading {
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private let lock = NSLock()
    private var tasks: [ObjectIdentifier: URLSessionDataTask] = [:]

    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 200
    }

    func loadImage(from url: URL?, bindTo token: AnyObject, completion: @escaping (UIImage?) -> Void) {
        cancelLoad(for: token)
        guard let url else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        let id = ObjectIdentifier(token)
        let task = session.dataTask(with: url) { [weak self] data, _, _ in
            defer {
                self?.lock.lock()
                self?.tasks.removeValue(forKey: id)
                self?.lock.unlock()
            }
            guard let self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }
        }
        lock.lock()
        tasks[id] = task
        lock.unlock()
        task.resume()
    }

    func cancelLoad(for token: AnyObject) {
        lock.lock()
        let id = ObjectIdentifier(token)
        tasks.removeValue(forKey: id)?.cancel()
        lock.unlock()
    }
}
