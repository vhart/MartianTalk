import Quick
import Nimble
import RxSwift

@testable import MartianNewsReader

class ArticleListViewControllerViewModelSpec: QuickSpec {
    override func spec() {
        describe("ArticleListViewController") {
            var viewModel: ArticleListViewController.ViewModel!
            var mockProvider: MockArticleProvider!
            var mockPreferences: MockLanguagePreferences!

            beforeEach {
                mockProvider = MockArticleProvider()
                mockPreferences = MockLanguagePreferences()
                let mockTranslatorGenerator = MockStringTranslatorGenerator()
                viewModel = ArticleListViewController.ViewModel(articlesProvider: mockProvider,
                                                                languagePreferences: mockPreferences,
                                                                translatorGenerator: mockTranslatorGenerator)
            }

            context("loadArticles()") {

                it("requests the article list on the articles provider") {
                    let disposeBag = DisposeBag()
                    var didRequest = false

                    mockProvider.methodCall
                        .subscribe(onNext: { method in
                            if method == .getList { didRequest = true }
                        }).disposed(by: disposeBag)

                    viewModel.loadArticles()

                    expect(didRequest) == true
                }

                context("on a successful load") {
                    it("emits a reload event") {
                        let disposeBag = DisposeBag()
                        var didEmitReload = false

                        viewModel.tableViewAction.asObservable()
                            .subscribe(onNext: { action in
                                if action == .reload { didEmitReload = true }
                            }).disposed(by: disposeBag)

                        viewModel.loadArticles()

                        expect(didEmitReload) == true
                    }
                }
            }

            context("cellViewModelForArticle(atRow:)") {
                beforeEach {
                    viewModel.loadArticles()
                }

                it("returns a view model with properties matching the corresponding article") {
                    let firstArticle = mockProvider.articles.first!

                    let vm = viewModel.cellViewModelForArticle(atRow: 0)

                    expect(vm.title) == MockStringTranslator.translationText
                    expect(vm.imageURL) == firstArticle.imageURL
                }
            }

            context("getArticle(forRow:)") {
                beforeEach {
                    viewModel.loadArticles()
                }

                it("returns the article matching that index") {
                    let thirdArticle = mockProvider.articles[2]
                    let article = viewModel.getArticle(forRow: 2)

                    expect(article.title) == thirdArticle.title
                    expect(article.body) == thirdArticle.body
                    expect(article.imageURL) == thirdArticle.imageURL
                }
            }

            context("articleCount") {
                beforeEach {
                    viewModel.loadArticles()
                }
                it("returns the number of articles given by the provider") {
                    expect(viewModel.articlesCount) == mockProvider.articles.count
                }
            }

            context("languageSelectionIndex") {
                context("when the preference gets updated to .english") {
                    it("emits a 0 index") {
                        let disposeBag = DisposeBag()
                        var didReceiveIndex = false

                        viewModel.languageSelectionIndex
                            .skip(1)
                            .take(1)
                            .subscribe(onNext: { index in
                                if index == 0 { didReceiveIndex = true }
                            }).disposed(by: disposeBag)

                        mockPreferences.save(preference: .english)

                        expect(didReceiveIndex) == true
                    }
                }

                context("when the preference gets updated to .martian") {
                    it("emits a 1 index") {
                        let disposeBag = DisposeBag()
                        var didReceiveIndex = false

                        viewModel.languageSelectionIndex
                            .skip(1)
                            .take(1)
                            .subscribe(onNext: { index in
                                if index == 1 { didReceiveIndex = true }
                            }).disposed(by: disposeBag)

                        mockPreferences.save(preference: .martian)

                        expect(didReceiveIndex) == true
                    }
                }
            }

            context("select(segment:)") {
                it("updates the language preferences") {
                    let disposeBag = DisposeBag()
                    var languageDidUpdate = false
                    let expectedLanguage = LanguageType.martian

                    mockPreferences.methodCall
                        .subscribe(onNext: { methodCall in
                            switch methodCall {
                            case .save(let language):
                                if language == expectedLanguage { languageDidUpdate = true }
                            case .getPrefferedLanguage: break
                            }
                        }).disposed(by: disposeBag)

                    viewModel.select(segment: 1)

                    expect(languageDidUpdate).toEventually(beTrue())
                }
            }
        }
    }
}
