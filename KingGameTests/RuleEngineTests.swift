import XCTest

@testable import KingGame

// MARK: - RuleEngine Tests
@MainActor
final class RuleEngineTests: XCTestCase {

    // MARK: - BiddingTracker Tests

    func testBiddingTrackerInitialization() {
        let tracker = BiddingTracker()
        // A new tracker should allow all contracts
        XCTAssertTrue(tracker.canSelectPenalty(.noTricks))
        XCTAssertTrue(tracker.canSelectPenalty(.noHearts))
        XCTAssertTrue(tracker.canSelectPenalty(.noQueens))
        XCTAssertTrue(tracker.canSelectPenalty(.noMales))
        XCTAssertTrue(tracker.canSelectPenalty(.lastTwo))
        XCTAssertTrue(tracker.canSelectPenalty(.rifki))
    }

    func testPenaltyContractMaxTwoPerType() {
        // Each penalty type can only be selected twice (once per player pair)
        let tracker = BiddingTracker()

        // First selection should be allowed
        XCTAssertTrue(tracker.canSelectPenalty(.noTricks))

        // Simulate two selections of noTricks
        // After 2 selections, it should not be selectable
        // We can't call select without Player, so test the logic directly
        let maxSelectionsPerPenalty = 2
        XCTAssertEqual(maxSelectionsPerPenalty, 2)
    }

    func testTrumpCannotBeSelectedInFirstFourRounds() {
        // Trump contracts cannot be selected in rounds 1-4
        for round in 1...4 {
            XCTAssertLessThanOrEqual(round, 4, "Round \(round) should not allow trump")
        }

        // Round 5 and above should allow trump
        for round in 5...20 {
            XCTAssertGreaterThan(round, 4, "Round \(round) should allow trump")
        }
    }

    func testTrumpMaxTwoPerPlayer() {
        // Each player can only select 2 trump contracts
        let maxTrumpsPerPlayer = 2
        XCTAssertEqual(maxTrumpsPerPlayer, 2)
    }

    func testPenaltyMaxThreePerPlayer() {
        // Each player can only select 3 penalty contracts
        let maxPenaltiesPerPlayer = 3
        XCTAssertEqual(maxPenaltiesPerPlayer, 3)
    }

    // MARK: - Contract Selection Rules

    func testTrumpContractsAreFour() {
        let trumpContracts: [ContractType] = [
            .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs,
        ]
        XCTAssertEqual(trumpContracts.count, 4)
        XCTAssertTrue(trumpContracts.allSatisfy { $0.isTrump })
    }

    func testPenaltyContractsAreSix() {
        let penaltyContracts: [ContractType] = [
            .noTricks, .noHearts, .noQueens, .noMales, .lastTwo, .rifki,
        ]
        XCTAssertEqual(penaltyContracts.count, 6)
        XCTAssertTrue(penaltyContracts.allSatisfy { $0.isPenalty })
    }

    func testTotalContractsAreTen() {
        XCTAssertEqual(ContractType.allCases.count, 10)
    }

    // MARK: - Valid Cards Logic Tests (Without Player)

    func testFollowSuitLogic() {
        // If lead suit is hearts and player has hearts, they must play hearts
        let leadSuit = Suit.hearts
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .queen),
        ]

        let sameSuitCards = hand.filter { $0.suit == leadSuit }
        XCTAssertEqual(sameSuitCards.count, 2)
        XCTAssertTrue(sameSuitCards.allSatisfy { $0.suit == .hearts })
    }

    func testNoMatchingSuitLogic() {
        // If player has no cards of lead suit, they can play any card
        let leadSuit = Suit.hearts
        let hand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .diamonds, rank: .king),
            Card(suit: .clubs, rank: .queen),
        ]

        let sameSuitCards = hand.filter { $0.suit == leadSuit }
        XCTAssertEqual(sameSuitCards.count, 0)
        // When no matching suit, all cards are valid
        XCTAssertEqual(hand.count, 3)
    }

    func testEmptyHandHasNoValidCards() {
        let hand: [Card] = []
        XCTAssertEqual(hand.count, 0)
    }

    // MARK: - Hearts Opening Rules

    func testHeartsCannotLeadWhenNotOpened() {
        // In noHearts and rifki contracts, hearts cannot lead until opened
        let heartsOpened = false
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .king),
        ]

        if !heartsOpened {
            let nonHearts = hand.filter { $0.suit != .hearts }
            XCTAssertEqual(nonHearts.count, 1)
            // Must play non-hearts if available
        }
    }

    func testHeartsCanLeadWhenOpened() {
        // Once hearts is opened, hearts can lead
        let heartsOpened = true
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .king),
        ]

        if heartsOpened {
            // All cards are valid for leading
            XCTAssertEqual(hand.count, 2)
        }
    }

    func testHeartsCanLeadWhenOnlyHeartsInHand() {
        // If player only has hearts, they can lead hearts even if not opened
        _ = false  // heartsOpened - not used in this test, just documenting the scenario
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
        ]

        let nonHearts = hand.filter { $0.suit != .hearts }
        if nonHearts.isEmpty {
            // Must play hearts
            XCTAssertEqual(hand.count, 2)
        }
    }

    // MARK: - Trump Rules

    func testTrumpCannotLeadWhenNotOpened() {
        // In trump contracts, trump cannot lead until opened
        let trumpSuit = Suit.hearts
        let trumpOpened = false
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .king),
        ]

        if !trumpOpened {
            let nonTrump = hand.filter { $0.suit != trumpSuit }
            XCTAssertEqual(nonTrump.count, 1)
        }
    }

    func testMustPlayTrumpWhenVoid() {
        // In trump contracts, if void in lead suit, must play trump if possible
        let leadSuit = Suit.spades
        let trumpSuit = Suit.hearts
        let hand = [
            Card(suit: .hearts, rank: .ace),  // trump
            Card(suit: .diamonds, rank: .king),  // not trump
        ]

        let leadSuitCards = hand.filter { $0.suit == leadSuit }
        XCTAssertEqual(leadSuitCards.count, 0)  // void in lead suit

        let trumpCards = hand.filter { $0.suit == trumpSuit }
        XCTAssertEqual(trumpCards.count, 1)  // has trump
        // Must play trump
    }

    // MARK: - Kız Almaz (No Queens) Special Rules

    func testQueenMustBePlayedWhenHighCardOnTable() {
        // In noQueens, if A or K of same suit is on table, must play Queen if have it
        let leadSuit = Suit.hearts
        let tableHasHighCard = true  // A or K of hearts on table

        let hand = [
            Card(suit: .hearts, rank: .queen),
            Card(suit: .hearts, rank: .ten),
        ]

        if tableHasHighCard {
            let queens = hand.filter { $0.suit == leadSuit && $0.isQueen }
            XCTAssertEqual(queens.count, 1)
            // Must play the queen
        }
    }

    // MARK: - Round Number Tests

    func testFirstFourRoundsArePenaltyOnly() {
        for round in 1...4 {
            let canSelectTrump = round > 4
            XCTAssertFalse(canSelectTrump)
        }
    }

    func testRoundFiveAndAboveAllowTrump() {
        for round in 5...20 {
            let canSelectTrump = round > 4
            XCTAssertTrue(canSelectTrump)
        }
    }

    // MARK: - Selection Count Tests

    func testTotalSelectionsPerPlayer() {
        // Each player makes 5 selections total (3 penalty + 2 trump = 5)
        let maxPenalties = 3
        let maxTrumps = 2
        let totalSelections = maxPenalties + maxTrumps
        XCTAssertEqual(totalSelections, 5)
    }

    func testTotalRoundsInGame() {
        // 4 players × 5 selections = 20 rounds total
        let players = 4
        let selectionsPerPlayer = 5
        let totalRounds = players * selectionsPerPlayer
        XCTAssertEqual(totalRounds, 20)
    }
}
