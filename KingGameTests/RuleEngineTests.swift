import XCTest

@testable import KingGame

// MARK: - RuleEngine Tests
final class RuleEngineTests: XCTestCase {

    func testCanSelectTrumpInFirstFourRounds() {
        let player = Player(name: "Test", type: .human)
        var tracker = BiddingTracker()

        // First 4 rounds: no trump allowed
        for round in 1...4 {
            XCTAssertFalse(
                RuleEngine.canSelect(
                    contract: .trumpSpades,
                    player: player,
                    tracker: tracker,
                    roundNumber: round
                ))
        }

        // Round 5+: trump allowed
        XCTAssertTrue(
            RuleEngine.canSelect(
                contract: .trumpSpades,
                player: player,
                tracker: tracker,
                roundNumber: 5
            ))
    }

    func testCanSelectTrumpMaxTwo() {
        let player = Player(name: "Test", type: .human)
        var tracker = BiddingTracker()

        tracker.select(.trumpSpades, for: player)
        tracker.select(.trumpHearts, for: player)

        // Third trump not allowed
        XCTAssertFalse(
            RuleEngine.canSelect(
                contract: .trumpDiamonds,
                player: player,
                tracker: tracker,
                roundNumber: 10
            ))
    }

    func testCanSelectPenaltyMaxThree() {
        let player = Player(name: "Test", type: .human)
        var tracker = BiddingTracker()

        tracker.select(.noTricks, for: player)
        tracker.select(.noHearts, for: player)
        tracker.select(.noQueens, for: player)

        // Fourth penalty not allowed
        XCTAssertFalse(
            RuleEngine.canSelect(
                contract: .noMales,
                player: player,
                tracker: tracker,
                roundNumber: 10
            ))
    }

    func testCanSelectPenaltyMaxTwoPerType() {
        let player = Player(name: "Test", type: .human)
        var tracker = BiddingTracker()

        tracker.select(.noTricks, for: player)
        tracker.select(.noTricks, for: player)

        // Third time same penalty not allowed (global limit)
        XCTAssertFalse(
            RuleEngine.canSelect(
                contract: .noTricks,
                player: player,
                tracker: tracker,
                roundNumber: 10
            ))
    }

    func testValidCardsEmptyHand() {
        let player = Player(name: "Test", type: .human)
        let round = Round(roundNumber: 1, contract: .noTricks, contractOwner: player)

        let validCards = RuleEngine.validCards(
            for: player,
            trick: nil,
            round: round,
            heartsOpened: false
        )

        XCTAssertEqual(validCards.count, 0)
    }

    func testValidCardsLeadPenaltyNoHearts() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .king),
            Card(suit: .diamonds, rank: .queen),
        ]

        let round = Round(roundNumber: 1, contract: .noHearts, contractOwner: player)

        // Hearts not opened yet - can't lead hearts
        let validCards = RuleEngine.validCards(
            for: player,
            trick: nil,
            round: round,
            heartsOpened: false
        )

        XCTAssertTrue(validCards.allSatisfy { $0.suit != .hearts })
        XCTAssertEqual(validCards.count, 2)
    }

    func testValidCardsLeadPenaltyNoHeartsOpened() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .king),
        ]

        let round = Round(roundNumber: 1, contract: .noHearts, contractOwner: player)

        // Hearts already opened - can lead anything
        let validCards = RuleEngine.validCards(
            for: player,
            trick: nil,
            round: round,
            heartsOpened: true
        )

        XCTAssertEqual(validCards.count, 2)
    }

    func testValidCardsFollowSameSuit() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .queen),
        ]

        var trick = Trick(leadSuit: .hearts, trickNumber: 1)
        trick.cards.append(
            (player: Player(name: "P1", type: .aiBalanced), card: Card(suit: .hearts, rank: .two)))

        let round = Round(roundNumber: 1, contract: .noTricks, contractOwner: player)

        let validCards = RuleEngine.validCards(
            for: player,
            trick: trick,
            round: round,
            heartsOpened: true
        )

        // Must follow suit
        XCTAssertTrue(validCards.allSatisfy { $0.suit == .hearts })
        XCTAssertEqual(validCards.count, 2)
    }

    func testValidCardsNoQueensRule() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .hearts, rank: .queen),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .spades, rank: .king),
        ]

        var trick = Trick(leadSuit: .hearts, trickNumber: 1)
        // Add high card (Ace) to trick
        trick.cards.append(
            (player: Player(name: "P1", type: .aiBalanced), card: Card(suit: .hearts, rank: .ace)))

        let round = Round(roundNumber: 1, contract: .noQueens, contractOwner: player)

        let validCards = RuleEngine.validCards(
            for: player,
            trick: trick,
            round: round,
            heartsOpened: true
        )

        // Must play queen if have it and high card on table
        XCTAssertTrue(validCards.contains { $0.isQueen })
        XCTAssertEqual(validCards.count, 1)  // Only queen allowed
    }

    func testValidCardsTrumpGame() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .diamonds, rank: .queen),
        ]

        var trick = Trick(leadSuit: .diamonds, trickNumber: 1)
        trick.cards.append(
            (player: Player(name: "P1", type: .aiBalanced), card: Card(suit: .diamonds, rank: .two))
        )

        let round = Round(roundNumber: 1, contract: .trumpSpades, contractOwner: player)
        round.trumpOpened = true

        let validCards = RuleEngine.validCards(
            for: player,
            trick: trick,
            round: round,
            heartsOpened: false
        )

        // Must follow suit (diamonds)
        XCTAssertTrue(validCards.allSatisfy { $0.suit == .diamonds })
    }

    func testValidCardsTrumpMustPlayTrump() {
        let player = Player(name: "Test", type: .human)
        player.hand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .diamonds, rank: .queen),
        ]

        var trick = Trick(leadSuit: .hearts, trickNumber: 1)
        trick.cards.append(
            (player: Player(name: "P1", type: .aiBalanced), card: Card(suit: .hearts, rank: .two)))

        let round = Round(roundNumber: 1, contract: .trumpSpades, contractOwner: player)
        round.trumpOpened = true

        let validCards = RuleEngine.validCards(
            for: player,
            trick: trick,
            round: round,
            heartsOpened: false
        )

        // No hearts, must play trump (spades)
        XCTAssertTrue(validCards.allSatisfy { $0.suit == .spades })
    }
}
