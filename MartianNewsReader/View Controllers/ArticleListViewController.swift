import UIKit
import RxSwift

final class ArticleListViewController: UIViewController {
    fileprivate let CellIdentifier = "Cell"

    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var viewModel = ViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        bindUiToViewModel()
        viewModel.loadArticles()
    }

    private func bindUiToViewModel() {
        viewModel.tableViewAction
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .reload: self?.tableView.reloadData()
                }
            }).disposed(by: disposeBag)

        viewModel.languageSelectionIndex
            .observeOn(MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] segment in
                self?.languageSegmentedControl.selectedSegmentIndex = segment
            }).disposed(by: disposeBag)

        viewModel.loadingError
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                // TODO: Customized error handling
                self?.presentErrorAlert(message: "An error occurred")
            }).disposed(by: disposeBag)
    }

    @IBAction func languageSegmentChanged(_ sender: UISegmentedControl) {
        viewModel.select(segment: sender.selectedSegmentIndex)
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "Uh oh", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }
}

extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articlesCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier,
                                                 for: indexPath) as! ArticleTableViewCell

        let cellViewModel = viewModel.cellViewModelForArticle(atRow: indexPath.row)
        cell.viewModel = cellViewModel

        return cell
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ArticleTableViewCell else { fatalError("Unrecognized cell") }
        cell.viewModel?.cancelRequests()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.getArticle(forRow: indexPath.row)
        let vc = ArticleDetailViewController.fromStoryboard(article: article)
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension ArticleListViewController {
    enum TableViewAction {
        case reload
    }

    class ViewModel {
        private var articles = [Article]() {
            didSet {
                tableViewAction.onNext(.reload)
            }
        }

        private let articlesProvider: ArticleListProviding
        private let languagePreferences: LanguagePreferenceProvider
        private let translatorGenerator: StringTranslatorGenerator
        private var currentPreference: Variable<LanguageType>
        private let errorSubject = PublishSubject<RetrievalError>()
        private let disposeBag = DisposeBag()

        private let languageSelectionBuffer = PublishSubject<LanguageType>()
        private let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.martian-news-reader.article-list-view-controller.view-model")

        var tableViewAction = PublishSubject<TableViewAction>()

        var loadingError: Observable<RetrievalError> { return errorSubject.asObservable() }

        var languageSelectionIndex: Observable<Int> {
            return currentPreference.asObservable().map { language in
                switch language {
                case .english: return 0
                case .martian: return 1
                }
            }
        }

        var articlesCount: Int { return articles.count }

        init(articlesProvider: ArticleListProviding = ArticlesRetriever(),
             languagePreferences: LanguagePreferenceProvider = LanguagePreferenceProviderFactory.get(),
             translatorGenerator: StringTranslatorGenerator = StringTranslatorFactory()) {
            self.articlesProvider = articlesProvider
            self.translatorGenerator = translatorGenerator
            self.languagePreferences = languagePreferences
            self.currentPreference = Variable(languagePreferences.getPreferredLanguage())


            watchPreferences()
            watchLanguageSelectionBuffer()
        }


        func cellViewModelForArticle(atRow row: Int) -> ArticleTableViewCell.ViewModel {
            let translator = translatorGenerator.translator(for: currentPreference.value)

            let article = getArticle(forRow: row)
            let title = translator.translate(article.title)

            return ArticleTableViewCell.ViewModel(title: title,
                                                  imageURL: article.imageURL)
        }

        func getArticle(forRow row: Int) -> Article {
            return articles[row]
        }

        func loadArticles() {
            articlesProvider.getList { [weak self] result in
                switch result {
                case .success(let articles): self?.articles = articles
                case .failure(let error): self?.errorSubject.onNext(error)
                }
            }
        }

        func select(segment: Int) {
            switch segment {
            case 0: languageSelectionBuffer.onNext(.english)
            case 1: languageSelectionBuffer.onNext(.martian)
            default: fatalError("Segment not accounted for")
            }
        }

        private func watchPreferences() {
            languagePreferences.preferenceUpdates
                .subscribe(onNext: { [weak self] language in
                    self?.currentPreference.value = language
                    self?.tableViewAction.onNext(.reload)
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
