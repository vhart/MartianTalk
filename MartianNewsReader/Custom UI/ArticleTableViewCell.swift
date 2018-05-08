import UIKit
import RxSwift

class ArticleTableViewCell: UITableViewCell {

    private var disposeBag = DisposeBag()

    lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true

        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.backgroundColor = .clear
        label.textColor = .black

        return label
    }()

    var viewModel: ViewModel? = nil {
        didSet {
            disposeBag = DisposeBag()
            bindUi()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutViews()
    }

    override func prepareForReuse() {
        imageView?.image = nil
        titleLabel.text = nil
        disposeBag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutViews()
    }

    func layoutViews() {
        contentView.addSubview(leftImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            leftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            leftImageView.widthAnchor.constraint(equalToConstant: 50),
            leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor),
            leftImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 5)
            ])
    }

    private func bindUi() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        viewModel.image
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.leftImageView.image = image ?? #imageLiteral(resourceName: "defaultIcon")
            }).disposed(by: disposeBag)
    }
}

extension ArticleTableViewCell {
    class ViewModel {
        let title: String
        let imageURL: URL
        let imageRetriever: ImageRetrieving
        let disposeBag = DisposeBag()

        private let imageSubject = Variable<UIImage?>(nil)
        var image: Observable<UIImage?> { return imageSubject.asObservable() }

        init(title: String,
             imageURL: URL,
             imageRetriever: ImageRetrieving = ImageStore.shared) {
            self.title = title
            self.imageURL = imageURL
            self.imageRetriever = imageRetriever

            getImage()
        }

        private func getImage() {
            imageRetriever.getImage(url: imageURL)
                .subscribe(onNext: { [weak self] (image) in
                    self?.imageSubject.value = image
                }).disposed(by: disposeBag)
        }

        func cancelRequests() {
            imageRetriever.cancelDownload(url: imageURL)
        }
    }
}
