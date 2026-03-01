import XCTest

@testable import KingGame

// MARK: - Card Tests (Basic)
@MainActor
final class CardTests: XCTestCase {

    func testCardInitialization() {
        let card = Card(suit: .hearts, rank: .king)
        XCTAssertEqual(card.suit, .hearts)
        XCTAssertEqual(card.rank, .king)
        XCTAssertNotNil(card.id)
    }

    func testCardIsRifki() {
        let rifki = Card(suit: .hearts, rank: .king)
        XCTAssertTrue(rifki.isRifki)

        let nonRifki = Card(suit: .hearts, rank: .queen)
        XCTAssertFalse(nonRifki.isRifki)
    }

    func testCardIsHeart() {
        let heart = Card(suit: .hearts, rank: .ace)
        XCTAssertTrue(heart.isHeart)

        let spade = Card(suit: .spades, rank: .ace)
        XCTAssertFalse(spade.isHeart)
    }

    func testSuitSymbol() {
        XCTAssertEqual(Suit.spades.symbol, "♠")
        XCTAssertEqual(Suit.hearts.symbol, "♥")
        XCTAssertEqual(Suit.diamonds.symbol, "♦")
        XCTAssertEqual(Suit.clubs.symbol, "♣")
    }

    func testRankComparison() {
        XCTAssertTrue(Rank.two < Rank.three)
        XCTAssertTrue(Rank.ace > Rank.king)
    }
}
