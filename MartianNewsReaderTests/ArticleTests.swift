import XCTest
@testable import MartianNewsReader

class ArticleTests: XCTestCase {
    
    func testArticleFailableInitializerPasses() {
        let title = "Welcome to the Test!"
        let body = "Or if you'd rather, check out The New York Times online."
        let urlString = "www.example.com"

        let dictionary: [String : Any] = ["title": title, "body": body, "images": [["top_image": true, "url": urlString]]]
        
        
        let article = Article.init(dictionary: dictionary)

        XCTAssertNotNil(article)
        XCTAssert(article?.title == "Welcome to the Test!")
        XCTAssert(article?.body == "Or if you'd rather, check out The New York Times online.")
        XCTAssert(article?.imageURL.absoluteString == urlString)
    }
    
    func testArticleFailableInitializerFails() {
        let body = "Or if you'd rather, check out The New York Times online."
        let dictionary: [String : Any] = ["body": body, "images": [["top_image": false]]]

        let article = Article.init(dictionary: dictionary)
        XCTAssertNil(article)
    }
}
