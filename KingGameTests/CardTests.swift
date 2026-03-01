import XCTest

@testable import KingGame

// MARK: - Card Tests
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

        let otherKing = Card(suit: .spades, rank: .king)
        XCTAssertFalse(otherKing.isRifki)
    }

    func testCardIsQueen() {
        let queen = Card(suit: .diamonds, rank: .queen)
        XCTAssertTrue(queen.isQueen)

        let king = Card(suit: .diamonds, rank: .king)
        XCTAssertFalse(king.isQueen)
    }

    func testCardIsMale() {
        let king = Card(suit: .spades, rank: .king)
        XCTAssertTrue(king.isMale)

        let jack = Card(suit: .clubs, rank: .jack)
        XCTAssertTrue(jack.isMale)

        let queen = Card(suit: .hearts, rank: .queen)
        XCTAssertFalse(queen.isMale)

        let ace = Card(suit: .diamonds, rank: .ace)
        XCTAssertFalse(ace.isMale)
    }

    func testCardIsHeart() {
        let heart = Card(suit: .hearts, rank: .ace)
        XCTAssertTrue(heart.isHeart)

        let spade = Card(suit: .spades, rank: .ace)
        XCTAssertFalse(spade.isHeart)
    }

    func testCardDisplayName() {
        let card = Card(suit: .spades, rank: .king)
        XCTAssertEqual(card.displayName, "King ♠")

        let heartCard = Card(suit: .hearts, rank: .ace)
        XCTAssertEqual(heartCard.displayName, "Ace ♥")
    }

    func testCardShortName() {
        let card = Card(suit: .spades, rank: .king)
        XCTAssertEqual(card.shortName, "K♠")

        let ace = Card(suit: .hearts, rank: .ace)
        XCTAssertEqual(ace.shortName, "A♥")
    }

    func testCardImageName() {
        let aceOfSpades = Card(suit: .spades, rank: .ace)
        XCTAssertEqual(aceOfSpades.imageName, "spade_1")

        let kingOfHearts = Card(suit: .hearts, rank: .king)
        XCTAssertEqual(kingOfHearts.imageName, "heart_king")

        let twoOfDiamonds = Card(suit: .diamonds, rank: .two)
        XCTAssertEqual(twoOfDiamonds.imageName, "diamond_2")
    }

    func testCardEquality() {
        let card1 = Card(suit: .hearts, rank: .king)
        let card2 = Card(suit: .hearts, rank: .king)
        let card3 = Card(suit: .spades, rank: .king)

        // Different IDs, so not equal
        XCTAssertNotEqual(card1, card2)
        XCTAssertNotEqual(card1, card3)
    }

    func testSuitIsRed() {
        XCTAssertTrue(Suit.hearts.isRed)
        XCTAssertTrue(Suit.diamonds.isRed)
        XCTAssertFalse(Suit.spades.isRed)
        XCTAssertFalse(Suit.clubs.isRed)
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
        XCTAssertTrue(Rank.queen > Rank.jack)
    }

    func testRankShortName() {
        XCTAssertEqual(Rank.two.shortName, "2")
        XCTAssertEqual(Rank.ten.shortName, "10")
        XCTAssertEqual(Rank.jack.shortName, "J")
        XCTAssertEqual(Rank.queen.shortName, "Q")
        XCTAssertEqual(Rank.king.shortName, "K")
        XCTAssertEqual(Rank.ace.shortName, "A")
    }
}

