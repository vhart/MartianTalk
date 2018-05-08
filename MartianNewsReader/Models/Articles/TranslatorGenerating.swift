protocol StringTranslatorGenerator {
    func translator(for type: LanguageType) -> Translator<String, String>
}

struct StringTranslatorFactory: StringTranslatorGenerator {
    func translator(for type: LanguageType) -> Translator<String, String> {
        switch type {
        case .english: return EnglishStringTranslator()
        case .martian: return MartianStringTranslator()
        }
    }
}

