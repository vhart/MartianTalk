import Foundation

protocol ArticleListProviding {
    func getList(onComplete: @escaping (Result<[Article], RetrievalError>) -> Void)
}

struct ArticlesRetriever: ArticleListProviding {
    typealias Content = [[String: Any]]

    let session: AnyDataRetrievable<[[String: Any]]>
    let endpoint: URL

    init(session: AnyDataRetrievable<Content> = AnyDataRetrievable(NetworkRetriever<Content>()),
         url: URL = Article.defaultEndpoint) {
        self.session = session
        self.endpoint = url
    }

    func getList(onComplete: @escaping (Result<[Article], RetrievalError>) -> Void) {
        session.get(from: endpoint, decoding: .plist) { (result) in
            switch result {
            case .success(let content):
                let articles = content.compactMap { Article(dictionary: $0) }
                onComplete(.success(articles))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

