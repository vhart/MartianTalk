import Foundation

enum LanguageType: String {
    case english
    case martian
}

protocol DictionaryInitializable {
    init?(dictionary: [String: Any])
}

struct Article {
    enum Keys: String {
        case title
        case body
        case images
        case topImage = "top_image"
        case url
    }

    let imageURL: URL
    let title: String
    let body: String
}

extension Article: DictionaryInitializable {
    init?(dictionary: [String: Any]) {
        guard let title = dictionary[Keys.title.rawValue] as? String,
            let body = dictionary[Keys.body.rawValue] as? String,
            let images = dictionary[Keys.images.rawValue] as? [[String: Any]]
            else { return nil }

        let topImageDicts = images.filter { ($0[Keys.topImage.rawValue] as? Bool) == true }

        guard let topImageDict = topImageDicts.first,
            let imageURLString = topImageDict[Keys.url.rawValue] as? String,
            let imageURL = URL(string: imageURLString)
            else { return nil }

        self.title = title
        self.body = body
        self.imageURL = imageURL
    }
}

extension Article {
    static let defaultEndpoint = URL(string: "http://mobile.public.ec2.nytimes.com.s3-website-us-east-1.amazonaws.com/candidates/content/v1/articles.plist")!
}
