import XCTest

@testable import KingGame

// MARK: - AIDecisionEngine Tests
@MainActor
final class AIDecisionEngineTests: XCTestCase {

    func testSelectCardReturnsValidCard() {
        let player = Player(name: "AI", type: .aiBalanced)
        let card1 = Card(suit: .hearts, rank: .ace)
        let card2 = Card(suit: .spades, rank: .king)
        let validCards = [card1, card2]

        let round = Round(roundNumber: 1, contract: .noTricks, contractOwner: player)

        let selectedCard = AIDecisionEngine.selectCard(
            for: player,
            validCards: validCards,
            trick: nil,
            round: round,
            allPlayers: [],
            playedCards: []
        )

        XCTAssertTrue(validCards.contains(selectedCard))
    }

    func testSelectCardDifferentAITypes() {
        let card1 = Card(suit: .hearts, rank: .ace)
        let card2 = Card(suit: .hearts, rank: .two)
        let validCards = [card1, card2]

        let round = Round(
            roundNumber: 1, contract: .noTricks, contractOwner: Player(name: "Test", type: .human))

        let aggressivePlayer = Player(name: "Agg", type: .aiAggressive)
        let balancedPlayer = Player(name: "Bal", type: .aiBalanced)
        let calculatorPlayer = Player(name: "Calc", type: .aiCalculator)

        let aggCard = AIDecisionEngine.selectCard(
            for: aggressivePlayer,
            validCards: validCards,
            trick: nil,
            round: round,
            allPlayers: [],
            playedCards: []
        )

        let balCard = AIDecisionEngine.selectCard(
            for: balancedPlayer,
            validCards: validCards,
            trick: nil,
            round: round,
            allPlayers: [],
            playedCards: []
        )

        let calcCard = AIDecisionEngine.selectCard(
            for: calculatorPlayer,
            validCards: validCards,
            trick: nil,
            round: round,
            allPlayers: [],
            playedCards: []
        )

        XCTAssertTrue(validCards.contains(aggCard))
        XCTAssertTrue(validCards.contains(balCard))
        XCTAssertTrue(validCards.contains(calcCard))
    }

    func testRiskScoreNoTricks() {
        let round = Round(
            roundNumber: 1, contract: .noTricks, contractOwner: Player(name: "Test", type: .human))

        let lowCard = Card(suit: .spades, rank: .two)
        let highCard = Card(suit: .spades, rank: .ace)

        let lowRisk = AIDecisionEngine.riskScore(
            for: lowCard, in: round, trick: nil, playedCards: [])
        let highRisk = AIDecisionEngine.riskScore(
            for: highCard, in: round, trick: nil, playedCards: [])

        XCTAssertLessThan(lowRisk, highRisk)
    }

    func testRiskScoreNoHearts() {
        let round = Round(
            roundNumber: 1, contract: .noHearts, contractOwner: Player(name: "Test", type: .human))

        let heartCard = Card(suit: .hearts, rank: .ace)
        let nonHeartCard = Card(suit: .spades, rank: .ace)

        let heartRisk = AIDecisionEngine.riskScore(
            for: heartCard, in: round, trick: nil, playedCards: [])
        let nonHeartRisk = AIDecisionEngine.riskScore(
            for: nonHeartCard, in: round, trick: nil, playedCards: [])

        XCTAssertLessThan(nonHeartRisk, heartRisk)
    }

    func testRiskScoreRifki() {
        let round = Round(
            roundNumber: 1, contract: .rifki, contractOwner: Player(name: "Test", type: .human))

        let rifki = Card(suit: .hearts, rank: .king)
        let nonRifki = Card(suit: .spades, rank: .ace)

        let rifkiRisk = AIDecisionEngine.riskScore(
            for: rifki, in: round, trick: nil, playedCards: [])
        let nonRifkiRisk = AIDecisionEngine.riskScore(
            for: nonRifki, in: round, trick: nil, playedCards: [])

        XCTAssertLessThan(nonRifkiRisk, rifkiRisk)
        XCTAssertEqual(rifkiRisk, 1.0)
    }

    func testSelectContractWithValidation() {
        let player = Player(name: "AI", type: .aiBalanced)
        let tracker = BiddingTracker()

        // First 4 rounds - only penalties available
        let hand = [
            Card(suit: .spades, rank: .two),
            Card(suit: .hearts, rank: .three),
        ]

        let availableContracts: [ContractType] = [.noTricks, .trumpSpades]

        let selected = AIDecisionEngine.selectContract(
            for: player,
            availableContracts: availableContracts,
            hand: hand,
            tracker: tracker,
            roundNumber: 1
        )

        // Should select penalty (noTricks) because trump not allowed in round 1
        XCTAssertEqual(selected, .noTricks)
    }

    func testSelectContractFallback() {
        let player = Player(name: "AI", type: .aiBalanced)
        let tracker = BiddingTracker()
        let hand: [Card] = []

        // Empty available contracts - should fallback to noTricks
        let selected = AIDecisionEngine.selectContract(
            for: player,
            availableContracts: [],
            hand: hand,
            tracker: tracker,
            roundNumber: 5
        )

        XCTAssertEqual(selected, .noTricks)
    }

    func testEvaluateContractTrump() {
        let hand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .king),
            Card(suit: .spades, rank: .queen),
            Card(suit: .hearts, rank: .two),
        ]

        let score = AIDecisionEngine.evaluateContract(.trumpSpades, hand: hand)

        // Should have positive score with 3 trumps including high cards
        XCTAssertGreaterThan(score, 0)
    }

    func testEvaluateContractNoHearts() {
        let goodHand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .diamonds, rank: .king),
            Card(suit: .clubs, rank: .queen),
        ]

        let badHand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .hearts, rank: .queen),
        ]

        let goodScore = AIDecisionEngine.evaluateContract(.noHearts, hand: goodHand)
        let badScore = AIDecisionEngine.evaluateContract(.noHearts, hand: badHand)

        XCTAssertGreaterThan(goodScore, badScore)
    }

    func testEvaluateContractNoQueens() {
        let goodHand = [
            Card(suit: .spades, rank: .two),
            Card(suit: .hearts, rank: .three),
        ]

        let badHand = [
            Card(suit: .spades, rank: .queen),
            Card(suit: .hearts, rank: .queen),
        ]

        let goodScore = AIDecisionEngine.evaluateContract(.noQueens, hand: goodHand)
        let badScore = AIDecisionEngine.evaluateContract(.noQueens, hand: badHand)

        XCTAssertGreaterThan(goodScore, badScore)
    }
}

