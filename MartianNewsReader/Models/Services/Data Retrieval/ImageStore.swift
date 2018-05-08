import UIKit
import RxSwift
import Foundation

protocol ImageRetrieving {
    func getImage(url: URL) -> Observable<UIImage>
    func cancelDownload(url: URL)
}

enum FetchError: Error {
    case unknownError
}

class InProgressFetch<T> {
    let observable: Observable<T>
    var referenceCount: Int = 1

    init(observable: Observable<T>) {
        self.observable = observable
    }
}

class ImageStore: ImageRetrieving {
    static let shared = ImageStore()

    private var imagesForURL = [URL: UIImage]()
    private var tasks = [URL: InProgressFetch<UIImage>]()
    private let lock = NSRecursiveLock()

    private init() {}

    func getImage(url: URL) -> Observable<UIImage> {
        defer { lock.unlock() }
        lock.lock()

        if let image = imagesForURL[url] { return Observable.just(image) }
        if let onGoingTask = tasks[url] {
            onGoingTask.referenceCount += 1
            return onGoingTask.observable.share()
        }

        let observable = Observable<UIImage>.create { observer -> Disposable in
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data.init(contentsOf: url), let image = UIImage(data: data) {
                    observer.onNext(image)
                    self?.update(with: image, for: url)
                } else {
                    observer.onError(FetchError.unknownError)
                    self?.update(with: nil, for: url)
                }
            }
            return Disposables.create()
        }

        let fetchTask = InProgressFetch(observable: observable)
        tasks[url] = fetchTask

        return observable
    }

    func cancelDownload(url: URL) {
        defer { lock.unlock() }
        lock.lock()

        guard let onGoingTask = tasks[url] else { return }
        onGoingTask.referenceCount -= 1
        if onGoingTask.referenceCount == 0 {
            tasks[url] = nil
        }
    }

    private func update(with image: UIImage?, for url: URL) {
        defer { lock.unlock() }
        lock.lock()

        tasks[url] = nil
        imagesForURL[url] = image
    }
}
