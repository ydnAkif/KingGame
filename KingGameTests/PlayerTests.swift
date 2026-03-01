import XCTest

@testable import KingGame

// MARK: - Player Tests
final class PlayerTests: XCTestCase {

    func testPlayerInitialization() {
        let player = Player(name: "Test", type: .human)
        XCTAssertEqual(player.name, "Test")
        XCTAssertEqual(player.type, .human)
        XCTAssertNotNil(player.id)
        XCTAssertEqual(player.hand.count, 0)
        XCTAssertEqual(player.tricksWon, 0)
        XCTAssertEqual(player.roundScore, 0)
        XCTAssertEqual(player.totalScore, 0)
    }

    func testPlayerIsAI() {
        let human = Player(name: "Human", type: .human)
        XCTAssertFalse(human.isAI)

        let aiAggressive = Player(name: "AI Agg", type: .aiAggressive)
        XCTAssertTrue(aiAggressive.isAI)

        let aiBalanced = Player(name: "AI Bal", type: .aiBalanced)
        XCTAssertTrue(aiBalanced.isAI)

        let aiCalculator = Player(name: "AI Calc", type: .aiCalculator)
        XCTAssertTrue(aiCalculator.isCalculator)
    }

    func testPlayerRiskThreshold() {
        let human = Player(name: "Human", type: .human)
        XCTAssertEqual(human.riskThreshold, 1.0)

        let aiAggressive = Player(name: "AI Agg", type: .aiAggressive)
        XCTAssertEqual(aiAggressive.riskThreshold, 0.35)

        let aiBalanced = Player(name: "AI Bal", type: .aiBalanced)
        XCTAssertEqual(aiBalanced.riskThreshold, 0.50)

        let aiCalculator = Player(name: "AI Calc", type: .aiCalculator)
        XCTAssertEqual(aiCalculator.riskThreshold, 0.25)
    }

    func testPlayerPlayCard() {
        let player = Player(name: "Test", type: .human)
        let card = Card(suit: .hearts, rank: .ace)
        player.hand = [card]

        let playedCard = player.playCard(card)
        XCTAssertNotNil(playedCard)
        XCTAssertEqual(playedCard, card)
        XCTAssertEqual(player.hand.count, 0)
    }

    func testPlayerPlayCardNotFound() {
        let player = Player(name: "Test", type: .human)
        let card = Card(suit: .hearts, rank: .ace)
        let otherCard = Card(suit: .spades, rank: .king)
        player.hand = [card]

        let playedCard = player.playCard(otherCard)
        XCTAssertNil(playedCard)
        XCTAssertEqual(player.hand.count, 1)
    }

    func testPlayerHasCardSuit() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .king),
        ]

        XCTAssertTrue(player.hasCard(suit: .hearts))
        XCTAssertTrue(player.hasCard(suit: .spades))
        XCTAssertFalse(player.hasCard(suit: .diamonds))
    }

    func testPlayerHasQueen() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .queen),
            Card(suit: .spades, rank: .king),
        ]

        XCTAssertTrue(player.hasQueen(suit: .hearts))
        XCTAssertFalse(player.hasQueen(suit: .spades))
    }

    func testPlayerHasMaleCard() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .jack),
            Card(suit: .diamonds, rank: .ace),
        ]

        XCTAssertTrue(player.hasMaleCard(suit: .hearts))
        XCTAssertTrue(player.hasMaleCard(suit: .spades))
        XCTAssertFalse(player.hasMaleCard(suit: .diamonds))
    }

    func testPlayerHasRifki() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .ace),
        ]

        XCTAssertTrue(player.hasRifki)

        player.hand = [
            Card(suit: .hearts, rank: .queen),
            Card(suit: .spades, rank: .ace),
        ]

        XCTAssertFalse(player.hasRifki)
    }

    func testPlayerWinTrick() {
        let player = Player(name: "Test", type: .human)
        XCTAssertEqual(player.tricksWon, 0)

        player.winTrick()
        XCTAssertEqual(player.tricksWon, 1)

        player.winTrick()
        XCTAssertEqual(player.tricksWon, 2)
    }

    func testPlayerResetForNewRound() {
        let player = Player(name: "Test", type: .human)
        player.tricksWon = 5
        player.roundScore = 100
        player.wonCards = [Card(suit: .hearts, rank: .king)]

        player.resetForNewRound()

        XCTAssertEqual(player.tricksWon, 0)
        XCTAssertEqual(player.roundScore, 0)
        XCTAssertEqual(player.wonCards.count, 0)
        XCTAssertEqual(player.totalScore, 0)  // Should not change
    }

    func testPlayerResetForNewGame() {
        let player = Player(name: "Test", type: .human)
        player.hand = [Card(suit: .hearts, rank: .ace)]
        player.tricksWon = 5
        player.roundScore = 100
        player.totalScore = 500
        player.heartsPlayed = true
        player.wonCards = [Card(suit: .hearts, rank: .king)]

        player.resetForNewGame()

        XCTAssertEqual(player.hand.count, 0)
        XCTAssertEqual(player.tricksWon, 0)
        XCTAssertEqual(player.roundScore, 0)
        XCTAssertEqual(player.totalScore, 0)
        XCTAssertFalse(player.heartsPlayed)
        XCTAssertEqual(player.wonCards.count, 0)
    }
}
