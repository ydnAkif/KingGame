import XCTest

@testable import KingGame

// MARK: - Deck Tests (Basic)
@MainActor
final class DeckTests: XCTestCase {

    func testDeckInitialization() {
        let deck = Deck()
        XCTAssertEqual(deck.cards.count, 52)
    }

    func testDeckHasAllSuits() {
        let deck = Deck()
        let spades = deck.cards.filter { $0.suit == .spades }
        let hearts = deck.cards.filter { $0.suit == .hearts }
        XCTAssertEqual(spades.count, 13)
        XCTAssertEqual(hearts.count, 13)
    }

    func testDeckDeal() {
        var deck = Deck()
        let hands = deck.deal()
        XCTAssertEqual(hands.count, 4)
        XCTAssertEqual(hands[0].count, 13)
    }

    func testFindDiamondTwo() {
        let diamondTwo = Card(suit: .diamonds, rank: .two)
        let hands: [[Card]] = [[diamondTwo], [], [], []]
        let result = Deck.findDiamondTwo(in: hands)
        XCTAssertEqual(result, 0)
    }
}
