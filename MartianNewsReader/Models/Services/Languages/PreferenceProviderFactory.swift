class LanguagePreferenceProviderFactory {
    private static let shared = LanguagePreferenceProviderFactory()
    private var provider: LanguagePreferenceProvider = DefaultPreferenceProvider()

    static func get() -> LanguagePreferenceProvider {
        return shared.provider
    }

    static func set(provider: LanguagePreferenceProvider) {
        shared.provider = provider
    }
}
