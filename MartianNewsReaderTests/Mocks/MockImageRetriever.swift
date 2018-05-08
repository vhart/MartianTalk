import Foundation
import RxSwift
@testable import MartianNewsReader

struct MockImageRetriever: ImageRetrieving {

    enum MethodCall {
        case getImage(URL)
        case cancelDownload(URL)
    }

    var methodCallSubject = PublishSubject<MethodCall>()
    var methodCall: Observable<MethodCall> { return methodCallSubject.asObservable() }

    func getImage(url: URL) -> Observable<UIImage> {
        methodCallSubject.onNext(.getImage(url))
        return Observable.just(#imageLiteral(resourceName: "defaultIcon"))
    }

    func cancelDownload(url: URL) {
        methodCallSubject.onNext(.cancelDownload(url))
    }
}
