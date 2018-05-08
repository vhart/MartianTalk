import Quick
import Nimble
@testable import MartianNewsReader

class MartianStringTranslatorSpec: QuickSpec {
    override func spec() {
        describe("MartianStringTranslator") {

            var translator: MartianStringTranslator!

            beforeEach {
                translator = MartianStringTranslator()
            }

            context("translate(_:)") {
                context("when the input is The blue cup jumps!") {
                    it("returns 'The boinga cup boinga!'") {
                        expect(translator.translate("The blue cup jumps!")) == "The boinga cup boinga!"
                    }
                }

                context("when the input is **<<Squeeze I'd && color's") {
                    it("returns **<<Boinga I'd && boinga") {
                        expect(translator.translate("**<<Squeeze I'd && color's")) == "**<<Boinga I'd && boinga"
                    }
                }

                context("when the input is !@#$% #@! )((") {
                    it("returns !@#$% #@! )((") {
                        expect(translator.translate("!@#$% #@! )((")) == "!@#$% #@! )(("
                    }
                }

                context("when the input is 2004") {
                    it("returns 2004") {
                        expect(translator.translate("2004")) == "2004"
                    }
                }


                context("when the input is \"The blue,\" cup&jumps.") {
                    it("returns The boinga cup boinga!") {
                        expect(translator.translate("\"The blue,\" cup&jumps.")) == "\"The boinga,\" boinga."
                    }
                }
            }
        }
    }
}
