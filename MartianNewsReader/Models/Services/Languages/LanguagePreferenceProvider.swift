import Foundation
import RxSwift

protocol LanguagePreferenceProvider {
    func getPreferredLanguage() -> LanguageType
    func save(preference: LanguageType)

    var preferenceUpdates: Observable<LanguageType> { get }
}
