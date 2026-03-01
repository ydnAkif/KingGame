import XCTest

@testable import KingGame

// MARK: - Trick Tests
@MainActor
final class TrickTests: XCTestCase {

    // MARK: - Initialization Tests

    func testTrickInitialization() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        XCTAssertEqual(trick.cards.count, 0)
        XCTAssertEqual(trick.leadSuit, .hearts)
        XCTAssertEqual(trick.trickNumber, 1)
    }

    func testTrickInitializationWithNilLeadSuit() {
        let trick = Trick(leadSuit: nil, trickNumber: 5)
        XCTAssertNil(trick.leadSuit)
        XCTAssertEqual(trick.trickNumber, 5)
    }

    func testTrickInitializationDifferentSuits() {
        let spadeTrick = Trick(leadSuit: .spades, trickNumber: 1)
        XCTAssertEqual(spadeTrick.leadSuit, .spades)

        let heartTrick = Trick(leadSuit: .hearts, trickNumber: 2)
        XCTAssertEqual(heartTrick.leadSuit, .hearts)

        let diamondTrick = Trick(leadSuit: .diamonds, trickNumber: 3)
        XCTAssertEqual(diamondTrick.leadSuit, .diamonds)

        let clubTrick = Trick(leadSuit: .clubs, trickNumber: 4)
        XCTAssertEqual(clubTrick.leadSuit, .clubs)
    }

    // MARK: - AllCards Tests

    func testTrickAllCardsEmpty() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        XCTAssertEqual(trick.allCards.count, 0)
        XCTAssertTrue(trick.allCards.isEmpty)
    }

    // MARK: - Trick Number Tests

    func testTrickNumberRange() {
        for i in 1...13 {
            let trick = Trick(leadSuit: .hearts, trickNumber: i)
            XCTAssertEqual(trick.trickNumber, i)
        }
    }

    // MARK: - Card Properties Tests

    func testCardIsRifki() {
        let rifki = Card(suit: .hearts, rank: .king)
        XCTAssertTrue(rifki.isRifki)

        let notRifki1 = Card(suit: .spades, rank: .king)
        XCTAssertFalse(notRifki1.isRifki)

        let notRifki2 = Card(suit: .hearts, rank: .queen)
        XCTAssertFalse(notRifki2.isRifki)

        let notRifki3 = Card(suit: .diamonds, rank: .king)
        XCTAssertFalse(notRifki3.isRifki)

        let notRifki4 = Card(suit: .clubs, rank: .king)
        XCTAssertFalse(notRifki4.isRifki)
    }

    func testCardIsQueen() {
        let queenHearts = Card(suit: .hearts, rank: .queen)
        XCTAssertTrue(queenHearts.isQueen)

        let queenSpades = Card(suit: .spades, rank: .queen)
        XCTAssertTrue(queenSpades.isQueen)

        let king = Card(suit: .hearts, rank: .king)
        XCTAssertFalse(king.isQueen)

        let jack = Card(suit: .hearts, rank: .jack)
        XCTAssertFalse(jack.isQueen)
    }

    func testCardIsMale() {
        // Kings are male
        let kingHearts = Card(suit: .hearts, rank: .king)
        XCTAssertTrue(kingHearts.isMale)

        let kingSpades = Card(suit: .spades, rank: .king)
        XCTAssertTrue(kingSpades.isMale)

        // Jacks are male
        let jackHearts = Card(suit: .hearts, rank: .jack)
        XCTAssertTrue(jackHearts.isMale)

        let jackClubs = Card(suit: .clubs, rank: .jack)
        XCTAssertTrue(jackClubs.isMale)

        // Queens are NOT male
        let queen = Card(suit: .hearts, rank: .queen)
        XCTAssertFalse(queen.isMale)

        // Aces are NOT male
        let ace = Card(suit: .hearts, rank: .ace)
        XCTAssertFalse(ace.isMale)

        // Number cards are NOT male
        let ten = Card(suit: .hearts, rank: .ten)
        XCTAssertFalse(ten.isMale)
    }

    func testCardIsHeart() {
        let heartAce = Card(suit: .hearts, rank: .ace)
        XCTAssertTrue(heartAce.isHeart)

        let heartTwo = Card(suit: .hearts, rank: .two)
        XCTAssertTrue(heartTwo.isHeart)

        let spadeAce = Card(suit: .spades, rank: .ace)
        XCTAssertFalse(spadeAce.isHeart)

        let diamondAce = Card(suit: .diamonds, rank: .ace)
        XCTAssertFalse(diamondAce.isHeart)

        let clubAce = Card(suit: .clubs, rank: .ace)
        XCTAssertFalse(clubAce.isHeart)
    }

    // MARK: - Contract Type Tests

    func testContractTrumpSuit() {
        XCTAssertEqual(ContractType.trumpSpades.trumpSuit, .spades)
        XCTAssertEqual(ContractType.trumpHearts.trumpSuit, .hearts)
        XCTAssertEqual(ContractType.trumpDiamonds.trumpSuit, .diamonds)
        XCTAssertEqual(ContractType.trumpClubs.trumpSuit, .clubs)

        XCTAssertNil(ContractType.noTricks.trumpSuit)
        XCTAssertNil(ContractType.noHearts.trumpSuit)
        XCTAssertNil(ContractType.noQueens.trumpSuit)
        XCTAssertNil(ContractType.noMales.trumpSuit)
        XCTAssertNil(ContractType.lastTwo.trumpSuit)
        XCTAssertNil(ContractType.rifki.trumpSuit)
    }

    func testContractIsTrump() {
        XCTAssertTrue(ContractType.trumpSpades.isTrump)
        XCTAssertTrue(ContractType.trumpHearts.isTrump)
        XCTAssertTrue(ContractType.trumpDiamonds.isTrump)
        XCTAssertTrue(ContractType.trumpClubs.isTrump)

        XCTAssertFalse(ContractType.noTricks.isTrump)
        XCTAssertFalse(ContractType.noHearts.isTrump)
        XCTAssertFalse(ContractType.noQueens.isTrump)
        XCTAssertFalse(ContractType.noMales.isTrump)
        XCTAssertFalse(ContractType.lastTwo.isTrump)
        XCTAssertFalse(ContractType.rifki.isTrump)
    }

    func testContractIsPenalty() {
        XCTAssertTrue(ContractType.noTricks.isPenalty)
        XCTAssertTrue(ContractType.noHearts.isPenalty)
        XCTAssertTrue(ContractType.noQueens.isPenalty)
        XCTAssertTrue(ContractType.noMales.isPenalty)
        XCTAssertTrue(ContractType.lastTwo.isPenalty)
        XCTAssertTrue(ContractType.rifki.isPenalty)

        XCTAssertFalse(ContractType.trumpSpades.isPenalty)
        XCTAssertFalse(ContractType.trumpHearts.isPenalty)
        XCTAssertFalse(ContractType.trumpDiamonds.isPenalty)
        XCTAssertFalse(ContractType.trumpClubs.isPenalty)
    }

    func testContractTrickScore() {
        // Trump contracts give +50 per trick
        XCTAssertEqual(ContractType.trumpSpades.trickScore, 50)
        XCTAssertEqual(ContractType.trumpHearts.trickScore, 50)
        XCTAssertEqual(ContractType.trumpDiamonds.trickScore, 50)
        XCTAssertEqual(ContractType.trumpClubs.trickScore, 50)

        // Penalty contracts give 0 per trick (penalties are per card)
        XCTAssertEqual(ContractType.noTricks.trickScore, 0)
        XCTAssertEqual(ContractType.noHearts.trickScore, 0)
        XCTAssertEqual(ContractType.noQueens.trickScore, 0)
        XCTAssertEqual(ContractType.noMales.trickScore, 0)
        XCTAssertEqual(ContractType.lastTwo.trickScore, 0)
        XCTAssertEqual(ContractType.rifki.trickScore, 0)
    }

    // MARK: - Winner Tests (Empty Trick)

    func testTrickWinnerEmptyTrick() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        let winner = trick.winner(contract: .noTricks)
        XCTAssertNil(winner)
    }

    func testTrickWinnerEmptyTrickWithTrump() {
        let trick = Trick(leadSuit: .spades, trickNumber: 1)
        let winner = trick.winner(contract: .trumpHearts)
        XCTAssertNil(winner)
    }

    // MARK: - Suit Tests

    func testSuitSymbol() {
        XCTAssertEqual(Suit.spades.symbol, "♠")
        XCTAssertEqual(Suit.hearts.symbol, "♥")
        XCTAssertEqual(Suit.diamonds.symbol, "♦")
        XCTAssertEqual(Suit.clubs.symbol, "♣")
    }

    func testSuitIsRed() {
        XCTAssertTrue(Suit.hearts.isRed)
        XCTAssertTrue(Suit.diamonds.isRed)
        XCTAssertFalse(Suit.spades.isRed)
        XCTAssertFalse(Suit.clubs.isRed)
    }

    // MARK: - Rank Tests

    func testRankComparison() {
        XCTAssertTrue(Rank.two < Rank.three)
        XCTAssertTrue(Rank.ten < Rank.jack)
        XCTAssertTrue(Rank.jack < Rank.queen)
        XCTAssertTrue(Rank.queen < Rank.king)
        XCTAssertTrue(Rank.king < Rank.ace)
    }

    func testRankShortName() {
        XCTAssertEqual(Rank.two.shortName, "2")
        XCTAssertEqual(Rank.ten.shortName, "10")
        XCTAssertEqual(Rank.jack.shortName, "J")
        XCTAssertEqual(Rank.queen.shortName, "Q")
        XCTAssertEqual(Rank.king.shortName, "K")
        XCTAssertEqual(Rank.ace.shortName, "A")
    }

    // MARK: - Penalty Score Tests

    func testNoTricksPenaltyScore() {
        let card = Card(suit: .hearts, rank: .ace)
        // noTricks doesn't care about specific cards, scoring is per trick
        let score = ContractType.noTricks.penaltyScore(for: card, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(score, -50)
    }

    func testNoHeartsPenaltyScore() {
        let heartCard = Card(suit: .hearts, rank: .ace)
        let heartScore = ContractType.noHearts.penaltyScore(
            for: heartCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(heartScore, -30)

        let spadeCard = Card(suit: .spades, rank: .ace)
        let spadeScore = ContractType.noHearts.penaltyScore(
            for: spadeCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(spadeScore, 0)
    }

    func testNoQueensPenaltyScore() {
        let queenCard = Card(suit: .hearts, rank: .queen)
        let queenScore = ContractType.noQueens.penaltyScore(
            for: queenCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(queenScore, -100)

        let kingCard = Card(suit: .hearts, rank: .king)
        let kingScore = ContractType.noQueens.penaltyScore(
            for: kingCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(kingScore, 0)
    }

    func testNoMalesPenaltyScore() {
        let kingCard = Card(suit: .hearts, rank: .king)
        let kingScore = ContractType.noMales.penaltyScore(
            for: kingCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(kingScore, -60)

        let jackCard = Card(suit: .spades, rank: .jack)
        let jackScore = ContractType.noMales.penaltyScore(
            for: jackCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(jackScore, -60)

        let queenCard = Card(suit: .hearts, rank: .queen)
        let queenScore = ContractType.noMales.penaltyScore(
            for: queenCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(queenScore, 0)
    }

    func testLastTwoPenaltyScore() {
        let card = Card(suit: .hearts, rank: .ace)

        // Trick 12 (second to last) - penalty applies
        let trick12Score = ContractType.lastTwo.penaltyScore(
            for: card, trickNumber: 12, totalTricks: 13)
        XCTAssertEqual(trick12Score, -180)

        // Trick 13 (last) - penalty applies
        let trick13Score = ContractType.lastTwo.penaltyScore(
            for: card, trickNumber: 13, totalTricks: 13)
        XCTAssertEqual(trick13Score, -180)

        // Trick 11 - no penalty
        let trick11Score = ContractType.lastTwo.penaltyScore(
            for: card, trickNumber: 11, totalTricks: 13)
        XCTAssertEqual(trick11Score, 0)

        // Trick 1 - no penalty
        let trick1Score = ContractType.lastTwo.penaltyScore(
            for: card, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(trick1Score, 0)
    }

    func testRifkiPenaltyScore() {
        let rifkiCard = Card(suit: .hearts, rank: .king)
        let rifkiScore = ContractType.rifki.penaltyScore(
            for: rifkiCard, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(rifkiScore, -320)

        let otherKing = Card(suit: .spades, rank: .king)
        let otherScore = ContractType.rifki.penaltyScore(
            for: otherKing, trickNumber: 1, totalTricks: 13)
        XCTAssertEqual(otherScore, 0)
    }
}
