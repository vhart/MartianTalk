import Quick
import Nimble
@testable import MartianNewsReader

class ArticlesRetrieverSpec: QuickSpec {
    override func spec() {
        describe("ArticlesRetriever") {
            var retriever: ArticlesRetriever!

            beforeEach {
                retriever = ArticlesRetriever(session: AnyDataRetrievable(MockArticleDataRetriever()),
                                              url: Article.defaultEndpoint)
            }

            context("getList(onComplete:)") {
                it("returns a list of 3 articles") {
                    var list = [Article]()
                    retriever.getList(onComplete: { (result) in
                        switch result {
                        case .success(let articles): list = articles
                        case .failure(_): fail("expected success")
                        }
                    })

                    expect(list.count) == 3
                }
            }
        }
    }
}
