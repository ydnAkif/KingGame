import XCTest

@testable import KingGame

// MARK: - ContractType Tests
final class ContractTypeTests: XCTestCase {

    func testContractTypeCount() {
        XCTAssertEqual(ContractType.allCases.count, 10)
    }

    func testPenaltyContracts() {
        XCTAssertTrue(ContractType.noTricks.isPenalty)
        XCTAssertTrue(ContractType.noHearts.isPenalty)
        XCTAssertTrue(ContractType.noQueens.isPenalty)
        XCTAssertTrue(ContractType.noMales.isPenalty)
        XCTAssertTrue(ContractType.lastTwo.isPenalty)
        XCTAssertTrue(ContractType.rifki.isPenalty)
    }

    func testTrumpContracts() {
        XCTAssertTrue(ContractType.trumpSpades.isTrump)
        XCTAssertTrue(ContractType.trumpHearts.isTrump)
        XCTAssertTrue(ContractType.trumpDiamonds.isTrump)
        XCTAssertTrue(ContractType.trumpClubs.isTrump)
    }

    func testTrumpSuit() {
        XCTAssertEqual(ContractType.trumpSpades.trumpSuit, .spades)
        XCTAssertEqual(ContractType.trumpHearts.trumpSuit, .hearts)
        XCTAssertEqual(ContractType.trumpDiamonds.trumpSuit, .diamonds)
        XCTAssertEqual(ContractType.trumpClubs.trumpSuit, .clubs)
        XCTAssertNil(ContractType.noTricks.trumpSuit)
    }

    func testContractRawValues() {
        XCTAssertEqual(ContractType.noTricks.rawValue, "El Almaz")
        XCTAssertEqual(ContractType.trumpSpades.rawValue, "Maça Koz")
    }

    func testBiddingTrackerInitialization() {
        let tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        XCTAssertTrue(tracker.canSelectPenalty(.noTricks))
        XCTAssertTrue(tracker.canSelectTrump(player: player, currentRound: 5))
        XCTAssertTrue(tracker.canSelectPenalty(player: player))
    }

    func testBiddingTrackerPenaltyLimit() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        tracker.select(.noTricks, for: player)
        XCTAssertTrue(tracker.canSelectPenalty(.noTricks))

        tracker.select(.noTricks, for: player)
        XCTAssertFalse(tracker.canSelectPenalty(.noTricks))
    }

    func testBiddingTrackerTrumpLimit() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        XCTAssertFalse(tracker.canSelectTrump(player: player, currentRound: 1))
        XCTAssertFalse(tracker.canSelectTrump(player: player, currentRound: 4))
        XCTAssertTrue(tracker.canSelectTrump(player: player, currentRound: 5))

        tracker.select(.trumpSpades, for: player)
        tracker.select(.trumpHearts, for: player)
        XCTAssertFalse(tracker.canSelectTrump(player: player, currentRound: 10))
    }

    func testBiddingTrackerPenaltyPerPlayerLimit() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        tracker.select(.noTricks, for: player)
        tracker.select(.noHearts, for: player)
        tracker.select(.noQueens, for: player)

        XCTAssertFalse(tracker.canSelectPenalty(player: player))
    }
}
