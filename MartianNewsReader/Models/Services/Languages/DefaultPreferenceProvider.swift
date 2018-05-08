import Foundation
import RxSwift

enum LanguagePreferenceKeys: String {
    case languagePreference
}

class DefaultPreferenceProvider: LanguagePreferenceProvider {
    let keyValueStore: KeyValueStore

    private let preferenceSubject = Variable<LanguageType>(.english)

    var preferenceUpdates: Observable<LanguageType> { return preferenceSubject.asObservable() }

    init(keyValueStore: KeyValueStore = UserDefaultsStore()) {
        self.keyValueStore = keyValueStore
        let current = getPreferredLanguage()
        preferenceSubject.value = current
    }

    func getPreferredLanguage() -> LanguageType {
        guard let preferenceString = keyValueStore.string(forKey: LanguagePreferenceKeys.languagePreference.rawValue),
            let preference = LanguageType(rawValue: preferenceString) else {
                save(preference: .english)
                return .english
        }
        return preference
    }

    func save(preference: LanguageType) {
        keyValueStore.set(preference.rawValue, forKey: LanguagePreferenceKeys.languagePreference.rawValue)
        preferenceSubject.value = preference
    }
}
