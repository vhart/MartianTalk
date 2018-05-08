@testable import MartianNewsReader

class MockKeyValueStore: KeyValueStore {
    var dictionary = [String: Any]()

    func set(_ value: Any?, forKey key: String) {
        dictionary[key] = value
    }

    func string(forKey key: String) -> String? {
        return dictionary[key] as? String
    }
}
