import Foundation
import RxSwift

@testable import MartianNewsReader

struct MockArticleProvider: ArticleListProviding {

    enum MethodCall {
        case getList
    }

    var methodCallSubject = PublishSubject<MethodCall>()
    var methodCall: Observable<MethodCall> { return methodCallSubject.asObservable() }

    var articles: [Article] = [
        Article(imageURL: URL(string: "www.example.com")!,
                title: "First article",
                body: "First body"),
        Article(imageURL: URL(string: "www.example.com")!,
                title: "Second article",
                body: "Second body"),
        Article(imageURL: URL(string: "www.example.com")!,
                title: "Third article",
                body: "Third body")
    ]

    func getList(onComplete: @escaping (Result<[Article], RetrievalError>) -> Void) {
        methodCallSubject.onNext(.getList)
        onComplete(.success(articles))
    }
}
