import XCTest

@testable import KingGame

// MARK: - Player Tests
final class PlayerTests: XCTestCase {

    func testPlayerInitialization() {
        let player = Player(name: "Test", type: .human)
        XCTAssertEqual(player.name, "Test")
        XCTAssertEqual(player.type, .human)
        XCTAssertEqual(player.hand.count, 0)
        XCTAssertEqual(player.tricksWon, 0)
        XCTAssertEqual(player.roundScore, 0)
        XCTAssertEqual(player.totalScore, 0)
    }

    func testPlayerIsAI() {
        let human = Player(name: "Human", type: .human)
        XCTAssertFalse(human.isAI)

        let ai = Player(name: "AI", type: .aiAggressive)
        XCTAssertTrue(ai.isAI)
    }

    func testPlayerIsCalculator() {
        let calculator = Player(name: "Calc", type: .aiCalculator)
        XCTAssertTrue(calculator.isCalculator)

        let human = Player(name: "Human", type: .human)
        XCTAssertFalse(human.isCalculator)
    }

    func testPlayerRiskThreshold() {
        XCTAssertEqual(Player(name: "H", type: .human).riskThreshold, 1.0)
        XCTAssertEqual(Player(name: "A", type: .aiAggressive).riskThreshold, 0.35)
        XCTAssertEqual(Player(name: "B", type: .aiBalanced).riskThreshold, 0.50)
        XCTAssertEqual(Player(name: "C", type: .aiCalculator).riskThreshold, 0.25)
    }

    func testPlayerPlayCard() {
        let player = Player(name: "Test", type: .human)
        let card = Card(suit: .hearts, rank: .ace)
        player.hand = [card]

        let played = player.playCard(card)
        XCTAssertNotNil(played)
        XCTAssertEqual(player.hand.count, 0)
    }

    func testPlayerPlayCardNotFound() {
        let player = Player(name: "Test", type: .human)
        player.hand = [Card(suit: .hearts, rank: .ace)]

        let played = player.playCard(Card(suit: .spades, rank: .king))
        XCTAssertNil(played)
        XCTAssertEqual(player.hand.count, 1)
    }

    func testPlayerHasCardSuit() {
        let player = Player(name: "Test", type: .human)
        player.hand = [Card(suit: .hearts, rank: .ace)]

        XCTAssertTrue(player.hasCard(suit: .hearts))
        XCTAssertFalse(player.hasCard(suit: .spades))
    }

    func testPlayerHasQueen() {
        let player = Player(name: "Test", type: .human)
        player.hand = [Card(suit: .hearts, rank: .queen)]

        XCTAssertTrue(player.hasQueen(suit: .hearts))
        XCTAssertFalse(player.hasQueen(suit: .spades))
    }

    func testPlayerHasMaleCard() {
        let player = Player(name: "Test", type: .human)
        player.hand = [Card(suit: .hearts, rank: .king), Card(suit: .spades, rank: .jack)]

        XCTAssertTrue(player.hasMaleCard(suit: .hearts))
        XCTAssertTrue(player.hasMaleCard(suit: .spades))
    }

    func testPlayerHasRifki() {
        let player = Player(name: "Test", type: .human)
        player.hand = [Card(suit: .hearts, rank: .king)]

        XCTAssertTrue(player.hasRifki)

        player.hand = [Card(suit: .hearts, rank: .queen)]
        XCTAssertFalse(player.hasRifki)
    }

    func testPlayerWinTrick() {
        let player = Player(name: "Test", type: .human)
        XCTAssertEqual(player.tricksWon, 0)

        player.winTrick()
        XCTAssertEqual(player.tricksWon, 1)
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
    }
}
