import Quick
import Nimble
import RxSwift

@testable import MartianNewsReader

class ArticleTableViewCellViewModelSpec: QuickSpec {
    override func spec() {
        describe("ArticleTableViewCell_ViewModel") {
            context("init") {
                it("requests an image from the image retriever") {
                    let mockImageRetriever = MockImageRetriever()

                    var didRequestImage = false
                    let disposeBag = DisposeBag()

                    mockImageRetriever.methodCall
                        .subscribe(onNext: { event in
                            switch event {
                            case .getImage(_): didRequestImage = true
                            default: break
                            }
                        }).disposed(by: disposeBag)


                    let _ = ArticleTableViewCell.ViewModel(title: "title",
                                                           imageURL: URL(string: "www.example.com")!,
                                                           imageRetriever: mockImageRetriever)

                    expect(didRequestImage) == true
                }

                it("sets all properties") {
                    let mockImageRetriever = MockImageRetriever()
                    let url = URL(string: "www.example.com")!
                    let title = "title"
                    let viewModel = ArticleTableViewCell.ViewModel(title: title,
                                                                   imageURL: url,
                                                                   imageRetriever: mockImageRetriever)

                    expect(viewModel.title) == title
                    expect(viewModel.imageURL) == url
                }
            }

            context("cancelRequests()") {
                it("cancels the requests on the image retriever") {
                    let mockImageRetriever = MockImageRetriever()

                    var didCancelRequest = false
                    let disposeBag = DisposeBag()

                    mockImageRetriever.methodCall
                        .subscribe(onNext: { event in
                            switch event {
                            case .cancelDownload(_): didCancelRequest = true
                            default: break
                            }
                        }).disposed(by: disposeBag)


                    let viewModel = ArticleTableViewCell.ViewModel(title: "title",
                                                                   imageURL: URL(string: "www.example.com")!,
                                                                   imageRetriever: mockImageRetriever)
                    viewModel.cancelRequests()

                    expect(didCancelRequest) == true
                }
            }
        }
    }
}
