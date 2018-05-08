import Quick
import Nimble
import RxSwift

@testable import MartianNewsReader

class ArticleDetailViewModelSpec: QuickSpec {
    override func spec() {
        describe("ArticleDetailViewController_ViewModel") {
            var viewModel: ArticleDetailViewController.ViewModel!
            let article = Article(imageURL: URL(string: "www.example.com")!,
                                  title: "Some Title",
                                  body: "Some body")
            var mockPreferences: MockLanguagePreferences!
            var mockImageRetriever: MockImageRetriever!

            beforeEach {
                mockPreferences = MockLanguagePreferences()
                mockImageRetriever = MockImageRetriever()
                let mockTranslatorGenerator = MockStringTranslatorGenerator()
                viewModel = ArticleDetailViewController.ViewModel(article: article,
                                                                  languagePreferences: mockPreferences,
                                                                  imageRetriever: mockImageRetriever,
                                                                  translatorGenerator: mockTranslatorGenerator)
            }

            context("init(article:,languagePreferences:,imageRetriever:,translators:)") {
                it("sets up properties to reflect the translated article") {
                    let disposeBag = DisposeBag()

                    var title: String!
                    var body: String!
                    var image: UIImage!

                    viewModel.body.subscribe(onNext: { bodyText in
                        body = bodyText
                    }).disposed(by: disposeBag)

                    viewModel.title.subscribe(onNext: { titleText in
                        title = titleText
                    }).disposed(by: disposeBag)

                    viewModel.image.subscribe(onNext: { fetchedImage in
                        image = fetchedImage
                    }).disposed(by: disposeBag)

                    expect(title) == MockStringTranslator.translationText
                    expect(body) == MockStringTranslator.translationText
                    expect(image) == #imageLiteral(resourceName: "defaultIcon")
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
