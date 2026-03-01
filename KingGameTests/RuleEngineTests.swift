import XCTest

@testable import KingGame

// MARK: - RuleEngine Tests
final class RuleEngineTests: XCTestCase {

    func testCanSelectTrumpInFirstFourRounds() {
        let player = Player(name: "Test", type: .human)
        var tracker = BiddingTracker()

        for round in 1...4 {
            XCTAssertFalse(
                RuleEngine.canSelect(
                    contract: .trumpSpades,
                    player: player,
                    tracker: tracker,
                    roundNumber: round
                ))
        }

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

        XCTAssertTrue(validCards.allSatisfy { $0.suit == .hearts })
        XCTAssertEqual(validCards.count, 2)
    }
}
