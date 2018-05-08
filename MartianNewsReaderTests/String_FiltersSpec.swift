import Quick
import Nimble
@testable import MartianNewsReader

class String_FiltersSpec: QuickSpec {
    override func spec() {
        describe("String+Filters") {
            context("isCapitalized") {
                context("when the string is potato") {
                    it("returns false") {
                        expect("potato".isCapitalized) == false
                    }
                }
                context("when the string is Potato") {
                    it("returns true") {
                        expect("Potato".isCapitalized) == true
                    }
                }
            }

            context("removeCharacters(from:)") {
                let razzleString = "Raz$!efr4<<1e"
                context("when the forbidden set is .letters") {
                    it("returns $!4<<1") {
                        expect(razzleString.removeCharacters(from: .letters)) == "$!4<<1"
                    }
                }

                context("when the forbidden set is .punctuation") {
                    it("returns Raz$efr4<<1e") {
                        expect(razzleString.removeCharacters(from: .punctuationCharacters)) == "Raz$efr4<<1e"
                    }
                }
            }
        }
    }
}
