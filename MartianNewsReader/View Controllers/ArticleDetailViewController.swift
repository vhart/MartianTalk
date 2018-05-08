import UIKit
import RxSwift

final class ArticleDetailViewController: UIViewController {

    static func fromStoryboard(article: Article) -> ArticleDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleDetailViewController") as! ArticleDetailViewController
        vc.viewModel = ViewModel(article: article)

        return vc
    }

    @IBOutlet weak var languageSegmentedController: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var topImageView: UIImageView!

    private let disposeBag = DisposeBag()
    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        formatImageView()
        bindUiToViewModel()
    }

    @IBAction func languageSegmentChanged(_ sender: UISegmentedControl) {
        viewModel.select(segment: sender.selectedSegmentIndex)
    }

    private func formatImageView() {
        topImageView.contentMode = .scaleAspectFit
        topImageView.layer.masksToBounds = true
    }

    private func bindUiToViewModel() {
        viewModel.title
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                self?.titleLabel.text = title
            }).disposed(by: disposeBag)

        viewModel.body
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] body in
                self?.bodyTextView.text = body
            }).disposed(by: disposeBag)

        viewModel.image
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.topImageView.image = image ?? #imageLiteral(resourceName: "defaultIcon")
            }).disposed(by: disposeBag)

        viewModel.languageSelectionIndex
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] segment in
                self?.languageSegmentedController.selectedSegmentIndex = segment
            }).disposed(by: disposeBag)
    }
}

extension ArticleDetailViewController {
    class ViewModel {
        private let article: Article
        private let languagePreferences: LanguagePreferenceProvider
        private let translatorGenerator: StringTranslatorGenerator
        private var currentPreference: Variable<LanguageType>
        private let imageRetriever: ImageRetrieving
        private let disposeBag = DisposeBag()

        private let languageSelectionBuffer = PublishSubject<LanguageType>()
        private let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.martian-news-reader.article-detail-view-controller.view-model")

        private let titleSubject = Variable<String>("")
        private let bodySubject = Variable<String>("")
        private let imageSubject = Variable<UIImage?>(nil)

        var title: Observable<String> { return titleSubject.asObservable() }
        var body: Observable<String> { return bodySubject.asObservable() }
        var image: Observable<UIImage?> { return imageSubject.asObservable() }

        var languageSelectionIndex: Observable<Int> {
            return currentPreference.asObservable().map { language in
                switch language {
                case .english: return 0
                case .martian: return 1
                }
            }
        }

        init(article: Article,
             languagePreferences: LanguagePreferenceProvider = LanguagePreferenceProviderFactory.get(),
             imageRetriever: ImageRetrieving = ImageStore.shared,
             translatorGenerator: StringTranslatorGenerator = StringTranslatorFactory()) {
            self.article = article
            self.translatorGenerator = translatorGenerator
            self.languagePreferences = languagePreferences
            self.currentPreference = Variable(languagePreferences.getPreferredLanguage())
            self.imageRetriever = imageRetriever

            getArticleImage()
            watchPreferences()
            watchLanguageSelectionBuffer()
        }

        deinit {
            imageRetriever.cancelDownload(url: article.imageURL)
        }

        func select(segment: Int) {
            switch segment {
            case 0: languageSelectionBuffer.onNext(.english)
            case 1: languageSelectionBuffer.onNext(.martian)
            default: fatalError("Segment not accounted for")
            }
        }

        private func updateContent() {
            let translator = translatorGenerator.translator(for: currentPreference.value)

            let title = translator.translate(article.title)
            let body = translator.translate(article.body)

            titleSubject.value = title
            bodySubject.value = body
        }

        private func getArticleImage() {
            imageRetriever.getImage(url: article.imageURL)
                .subscribe(onNext: { [weak self] image in
                    self?.imageSubject.value = image
                }).disposed(by: disposeBag)
        }

        private func watchPreferences() {
            languagePreferences.preferenceUpdates
                .subscribe(onNext: { [weak self] language in
                    self?.currentPreference.value = language
                    self?.updateContent()
                }).disposed(by: disposeBag)
        }

        private func watchLanguageSelectionBuffer() {
            languageSelectionBuffer.asObservable()
                .debounce(0.4, scheduler: scheduler)
                .subscribe(onNext: { [weak self] language in
                    self?.languagePreferences.save(preference: language)
                }).disposed(by: disposeBag)
        }
    }
}
