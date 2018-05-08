import Quick
import Nimble
@testable import MartianNewsReader

class EnglishStringTranslatorSpec: QuickSpec {
    override func spec() {
        describe("EnglishStringTranslator") {
            var translator: EnglishStringTranslator!

            beforeEach {
                translator = EnglishStringTranslator()
            }

            context("translate(_:)") {
                context("when the input is The blue cup jumps!") {
                    it("returns The blue cup jumps!") {
                        expect(translator.translate("The blue cup jumps!")) == "The blue cup jumps!"
                    }
                }

                context("when the input is **<<Squeeze I'd && color's") {
                    it("returns **<<Squeeze I'd && color's") {
                        expect(translator.translate("**<<Squeeze I'd && color's")) == "**<<Squeeze I'd && color's"
                    }
                }

                context("when the input is !@#$% #@! )((") {
                    it("returns !@#$% #@! )((") {
                        expect(translator.translate("!@#$% #@! )((")) == "!@#$% #@! )(("
                    }
                }

                context("when the input is \"The blue,\" cup&jumps.") {
                    it("returns \"The blue,\" cup&jumps") {
                        expect(translator.translate("\"The blue,\" cup&jumps.")) == "\"The blue,\" cup&jumps."
                    }
                }
            }
        }
    }
}
