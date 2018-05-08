@testable import MartianNewsReader

class MockStringTranslator: Translator<String, String> {
    static let translationText = "Mock Translation"

    override func translate(_ value: String) -> String {
        return MockStringTranslator.translationText
    }
}
