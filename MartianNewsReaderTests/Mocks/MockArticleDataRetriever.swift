import Foundation
@testable import MartianNewsReader

class MockArticleDataRetriever: DataRetrieving {

    var dictionaries: [[String: Any]] = [
        ["title": "Welcome to the Test!",
         "body": "Or if you'd rather, check out The New York Times online.",
         "images": [
            ["top_image": true,
             "url": "www.example.com"]
            ]
        ],
        ["title": "Jump for joy?",
         "body": "Check out The New York Times online.",
         "images": [
            ["top_image": true,
             "url": "www.example.com"]
            ]
        ],
        ["title": "Spaghetti again?",
         "body": "Or if you'd rather, check out bow ties",
         "images": [
            ["top_image": true,
             "url": "www.example.com"]
            ]
        ]
    ]

    func get(from url: URL,
             decoding strategy: DecodingStrategy,
             onComplete: @escaping (Result<[[String : Any]], RetrievalError>) -> Void) {
        onComplete(.success(dictionaries))
    }
}
