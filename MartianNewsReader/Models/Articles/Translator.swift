import Foundation

class Translator<From, To> {
    init() {
        guard type(of: self) != Translator.self
            else { fatalError("do not initialize this abstract class directly") }
    }

    func translate(_ value: From) -> To {
        fatalError("abstract method")
    }
}

class MartianStringTranslator: Translator<String, String> {
    override func translate(_ value: String) -> String {
        return value.components(separatedBy: .newlines)
            .map { $0.components(separatedBy: .whitespaces)
                .map { translate(word: $0) }
                .joined(separator: " ")
            }.joined(separator: "\n")
    }

    private func translate(word: String) -> String {
        let validSet = CharacterSet.letters
        var coreWord = word
        var prefix = ""
        var suffix = ""

        if let first = word.indexOfFirst(containedIn: validSet) {
            let firstIndex = word.index(word.startIndex, offsetBy: first)
            prefix = String(word[..<firstIndex])

            if let last = word.indexOfLast(containedIn: validSet, lowerBound: first) {
                let lastValidIndex = word.index(word.startIndex, offsetBy: last)
                suffix = String(word[word.index(after: lastValidIndex)...])
                coreWord = String(word[firstIndex...lastValidIndex])
            } else {
                coreWord = String(word[firstIndex...])
            }
        } else {
            return word
        }

        let shouldCapitalize = coreWord.isCapitalized
        coreWord = coreWord.removeCharacters(from: .punctuationCharacters)

        guard coreWord.count > 3 else { return word }
        var replacement = "boinga"
        if shouldCapitalize { replacement = replacement.capitalized }

        replacement = prefix + replacement + suffix

        return replacement
    }
}

class EnglishStringTranslator: Translator<String, String> {
    override func translate(_ value: String) -> String {
        return value
    }
}
