import Foundation

protocol KeyValueStore {
    func set(_ value: Any?, forKey: String)
    func string(forKey: String) -> String?
}

struct UserDefaultsStore: KeyValueStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    func string(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
}
