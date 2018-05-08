import Foundation
import RxSwift
@testable import MartianNewsReader

class MockLanguagePreferences: LanguagePreferenceProvider {

    var methodCallSubject = PublishSubject<MethodCall>()
    var methodCall: Observable<MethodCall> { return methodCallSubject.asObservable() }

    enum MethodCall {
        case getPrefferedLanguage
        case save(LanguageType)
    }

    var preferenceSubject = Variable<LanguageType>(.english)

    var preferenceUpdates: Observable<LanguageType> { return preferenceSubject.asObservable() }

    func getPreferredLanguage() -> LanguageType {
        methodCallSubject.onNext(.getPrefferedLanguage)
        return preferenceSubject.value
    }

    func save(preference: LanguageType) {
        methodCallSubject.onNext(.save(preference))
        preferenceSubject.value = preference
    }
}
