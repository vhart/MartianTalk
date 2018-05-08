import Quick
import Nimble
import RxSwift
@testable import MartianNewsReader

class DefaultPreferenceProviderSpec: QuickSpec {
    override func spec() {
        describe("DefaultPreferenceProvider") {

            var provider: DefaultPreferenceProvider!
            var mockKVS: MockKeyValueStore!

            beforeEach {
                mockKVS = MockKeyValueStore()
                provider = DefaultPreferenceProvider(keyValueStore: mockKVS)
            }

            context("getPreferredLanguage()") {
                context("when there is no default set") {
                    beforeEach {
                        mockKVS.dictionary.removeAll()
                    }
                    it("returns .english") {
                        expect(provider.getPreferredLanguage()) == LanguageType.english
                    }

                    it("sets english to be the default in the store") {
                        expect(mockKVS.dictionary[LanguagePreferenceKeys.languagePreference.rawValue]).to(beNil())
                        _ = provider.getPreferredLanguage()
                        let newPreference = mockKVS.dictionary[LanguagePreferenceKeys.languagePreference.rawValue] as! String
                        expect(newPreference) == LanguageType.english.rawValue
                    }
                }

                context("when the default is set to .english") {
                    beforeEach {
                        mockKVS.dictionary[LanguagePreferenceKeys.languagePreference.rawValue] = LanguageType.english.rawValue
                    }

                    it("returns .english") {
                        expect(provider.getPreferredLanguage()) == LanguageType.english
                    }
                }

                context("when the default is set to .martian") {
                    beforeEach {
                        mockKVS.dictionary[LanguagePreferenceKeys.languagePreference.rawValue] = LanguageType.martian.rawValue
                    }

                    it("returns .english") {
                        expect(provider.getPreferredLanguage()) == LanguageType.martian
                    }
                }
            }

            context("save(preference:)") {

                beforeEach {
                    mockKVS.dictionary.removeAll()
                }

                it("updates the store with the preference") {
                    expect(mockKVS.dictionary[LanguagePreferenceKeys.languagePreference.rawValue]).to(beNil())
                    provider.save(preference: .martian)
                    let newValue = mockKVS.dictionary[LanguagePreferenceKeys.languagePreference.rawValue] as! String
                    expect(newValue) == LanguageType.martian.rawValue
                }
            }

            context("preferenceUpdates") {
                context("when a preference gets saved") {
                    it("emits an event with the new preference") {
                        let disposeBag = DisposeBag()
                        var didReceiveEvent = false

                        let preference = LanguageType.martian

                        provider.preferenceUpdates
                            .subscribe(onNext: { language in
                                if language == .martian {
                                    didReceiveEvent = true
                                }
                            }).disposed(by: disposeBag)

                        provider.save(preference: preference)

                        expect(didReceiveEvent) == true
                    }
                }
            }
        }
    }
}
