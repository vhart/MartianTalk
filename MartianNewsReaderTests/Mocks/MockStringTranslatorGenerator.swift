@testable import MartianNewsReader

struct MockStringTranslatorGenerator: StringTranslatorGenerator {
    func translator(for type: LanguageType) -> Translator<String, String> {
        return MockStringTranslator()
    }
}
