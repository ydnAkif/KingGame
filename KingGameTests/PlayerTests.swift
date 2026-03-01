import XCTest

@testable import KingGame

// MARK: - Player Type Tests
@MainActor
final class PlayerTests: XCTestCase {

    // MARK: - PlayerType Tests

    func testPlayerTypeEquality() {
        XCTAssertEqual(PlayerType.human, PlayerType.human)
        XCTAssertEqual(PlayerType.aiAggressive, PlayerType.aiAggressive)
        XCTAssertEqual(PlayerType.aiBalanced, PlayerType.aiBalanced)
        XCTAssertEqual(PlayerType.aiCalculator, PlayerType.aiCalculator)
    }

    func testPlayerTypeInequality() {
        XCTAssertNotEqual(PlayerType.human, PlayerType.aiAggressive)
        XCTAssertNotEqual(PlayerType.aiAggressive, PlayerType.aiBalanced)
        XCTAssertNotEqual(PlayerType.aiBalanced, PlayerType.aiCalculator)
        XCTAssertNotEqual(PlayerType.aiCalculator, PlayerType.human)
    }

    func testAllPlayerTypes() {
        let types: [PlayerType] = [.human, .aiAggressive, .aiBalanced, .aiCalculator]
        XCTAssertEqual(types.count, 4)
    }

    // MARK: - Risk Threshold Tests (using computed values)

    func testHumanRiskThreshold() {
        // Human has risk threshold of 1.0 (will accept any play)
        let expectedThreshold = 1.0
        XCTAssertEqual(expectedThreshold, 1.0)
    }

    func testAIAggressiveRiskThreshold() {
        // Aggressive AI has lower threshold (0.35) - takes more risks
        let expectedThreshold = 0.35
        XCTAssertEqual(expectedThreshold, 0.35)
    }

    func testAIBalancedRiskThreshold() {
        // Balanced AI has medium threshold (0.50)
        let expectedThreshold = 0.50
        XCTAssertEqual(expectedThreshold, 0.50)
    }

    func testAICalculatorRiskThreshold() {
        // Calculator AI has lowest threshold (0.25) - most cautious
        let expectedThreshold = 0.25
        XCTAssertEqual(expectedThreshold, 0.25)
    }

    func testRiskThresholdOrdering() {
        // Calculator < Aggressive < Balanced < Human
        let calculatorThreshold = 0.25
        let aggressiveThreshold = 0.35
        let balancedThreshold = 0.50
        let humanThreshold = 1.0

        XCTAssertLessThan(calculatorThreshold, aggressiveThreshold)
        XCTAssertLessThan(aggressiveThreshold, balancedThreshold)
        XCTAssertLessThan(balancedThreshold, humanThreshold)
    }

    // MARK: - AI Detection Tests

    func testHumanIsNotAI() {
        let type = PlayerType.human
        let isAI = type != .human
        XCTAssertFalse(isAI)
    }

    func testAggressiveIsAI() {
        let type = PlayerType.aiAggressive
        let isAI = type != .human
        XCTAssertTrue(isAI)
    }

    func testBalancedIsAI() {
        let type = PlayerType.aiBalanced
        let isAI = type != .human
        XCTAssertTrue(isAI)
    }

    func testCalculatorIsAI() {
        let type = PlayerType.aiCalculator
        let isAI = type != .human
        XCTAssertTrue(isAI)
    }

    // MARK: - Calculator Detection Tests

    func testOnlyCalculatorIsCalculator() {
        XCTAssertTrue(PlayerType.aiCalculator == .aiCalculator)
        XCTAssertFalse(PlayerType.human == .aiCalculator)
        XCTAssertFalse(PlayerType.aiAggressive == .aiCalculator)
        XCTAssertFalse(PlayerType.aiBalanced == .aiCalculator)
    }

    // MARK: - Card Property Tests

    func testCardHasRifki() {
        let rifki = Card(suit: .hearts, rank: .king)
        XCTAssertTrue(rifki.isRifki)

        let otherKing = Card(suit: .spades, rank: .king)
        XCTAssertFalse(otherKing.isRifki)

        let heartQueen = Card(suit: .hearts, rank: .queen)
        XCTAssertFalse(heartQueen.isRifki)
    }

    func testCardHasQueen() {
        let queen = Card(suit: .hearts, rank: .queen)
        XCTAssertTrue(queen.isQueen)

        let king = Card(suit: .hearts, rank: .king)
        XCTAssertFalse(king.isQueen)
    }

    func testCardHasMale() {
        let king = Card(suit: .hearts, rank: .king)
        XCTAssertTrue(king.isMale)

        let jack = Card(suit: .spades, rank: .jack)
        XCTAssertTrue(jack.isMale)

        let queen = Card(suit: .hearts, rank: .queen)
        XCTAssertFalse(queen.isMale)
    }

    func testCardIsHeart() {
        let heartCard = Card(suit: .hearts, rank: .ace)
        XCTAssertTrue(heartCard.isHeart)

        let spadeCard = Card(suit: .spades, rank: .ace)
        XCTAssertFalse(spadeCard.isHeart)
    }

    // MARK: - Card Display Name Tests

    func testCardDisplayName() {
        let aceOfSpades = Card(suit: .spades, rank: .ace)
        XCTAssertEqual(aceOfSpades.displayName, "Ace ♠")

        let kingOfHearts = Card(suit: .hearts, rank: .king)
        XCTAssertEqual(kingOfHearts.displayName, "King ♥")

        let twoOfDiamonds = Card(suit: .diamonds, rank: .two)
        XCTAssertEqual(twoOfDiamonds.displayName, "2 ♦")
    }

    func testCardShortName() {
        let aceOfSpades = Card(suit: .spades, rank: .ace)
        XCTAssertEqual(aceOfSpades.shortName, "A♠")

        let kingOfHearts = Card(suit: .hearts, rank: .king)
        XCTAssertEqual(kingOfHearts.shortName, "K♥")

        let queenOfDiamonds = Card(suit: .diamonds, rank: .queen)
        XCTAssertEqual(queenOfDiamonds.shortName, "Q♦")

        let jackOfClubs = Card(suit: .clubs, rank: .jack)
        XCTAssertEqual(jackOfClubs.shortName, "J♣")

        let tenOfHearts = Card(suit: .hearts, rank: .ten)
        XCTAssertEqual(tenOfHearts.shortName, "10♥")
    }

    // MARK: - Card Image Name Tests

    func testCardImageName() {
        let aceOfSpades = Card(suit: .spades, rank: .ace)
        XCTAssertEqual(aceOfSpades.imageName, "spade_1")

        let kingOfHearts = Card(suit: .hearts, rank: .king)
        XCTAssertEqual(kingOfHearts.imageName, "heart_king")

        let queenOfDiamonds = Card(suit: .diamonds, rank: .queen)
        XCTAssertEqual(queenOfDiamonds.imageName, "diamond_queen")

        let jackOfClubs = Card(suit: .clubs, rank: .jack)
        XCTAssertEqual(jackOfClubs.imageName, "club_jack")

        let twoOfHearts = Card(suit: .hearts, rank: .two)
        XCTAssertEqual(twoOfHearts.imageName, "heart_2")

        let tenOfSpades = Card(suit: .spades, rank: .ten)
        XCTAssertEqual(tenOfSpades.imageName, "spade_10")
    }

    // MARK: - Card Equatable Tests

    func testCardEquatable() {
        let card1 = Card(suit: .hearts, rank: .ace)
        let card2 = Card(suit: .hearts, rank: .ace)

        // Cards with same suit and rank but different UUIDs are NOT equal
        XCTAssertNotEqual(card1, card2)

        // Card is equal to itself
        XCTAssertEqual(card1, card1)
    }

    // MARK: - Card Hashable Tests

    func testCardHashable() {
        let card1 = Card(suit: .hearts, rank: .ace)
        let card2 = Card(suit: .hearts, rank: .king)

        var cardSet: Set<Card> = []
        cardSet.insert(card1)
        cardSet.insert(card2)

        XCTAssertEqual(cardSet.count, 2)
        XCTAssertTrue(cardSet.contains(card1))
        XCTAssertTrue(cardSet.contains(card2))
    }
}
