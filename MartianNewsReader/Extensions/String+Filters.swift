import Foundation

extension String {
    var isCapitalized: Bool {
        guard let first = unicodeScalars.first else { return false }
        return CharacterSet.uppercaseLetters.contains(first)
    }

    func removeCharacters(from forbidden: CharacterSet) -> String {
        let passed = unicodeScalars.filter { !forbidden.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }

    func indexOfFirst(containedIn validSet: CharacterSet) -> Int? {
        for i in 0..<unicodeScalars.count {
            let value = unicodeScalars[index(startIndex, offsetBy: i)]
            if validSet.contains(value) { return i }
        }
        return nil
    }

    func indexOfLast(containedIn validSet: CharacterSet, lowerBound: Int?) -> Int? {
        for i in (0..<unicodeScalars.count).reversed() {
            if let lower = lowerBound, lower >= i { return nil }
            let value = unicodeScalars[index(startIndex, offsetBy: i)]
            if validSet.contains(value) { return i }
        }
        return nil
    }
}
