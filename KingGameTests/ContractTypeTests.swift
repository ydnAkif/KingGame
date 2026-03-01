import XCTest
@testable import KingGame

// MARK: - ContractType Tests
final class ContractTypeTests: XCTestCase {

    func testContractTypeCount() {
        XCTAssertEqual(ContractType.allCases.count, 10, "Should have 10 contract types")
    }

    func testPenaltyContracts() {
        let penalties = ContractType.allCases.filter { $0.isPenalty }
        XCTAssertEqual(penalties.count, 6)

        XCTAssertTrue(ContractType.noTricks.isPenalty)
        XCTAssertTrue(ContractType.noHearts.isPenalty)
        XCTAssertTrue(ContractType.noQueens.isPenalty)
        XCTAssertTrue(ContractType.noMales.isPenalty)
        XCTAssertTrue(ContractType.lastTwo.isPenalty)
        XCTAssertTrue(ContractType.rifki.isPenalty)
    }

    func testTrumpContracts() {
        let trumps = ContractType.allCases.filter { $0.isTrump }
        XCTAssertEqual(trumps.count, 4)

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
        XCTAssertNil(ContractType.noHearts.trumpSuit)
    }

    func testContractRawValues() {
        XCTAssertEqual(ContractType.noTricks.rawValue, "El Almaz")
        XCTAssertEqual(ContractType.noHearts.rawValue, "Kupa Almaz")
        XCTAssertEqual(ContractType.noQueens.rawValue, "Kız Almaz")
        XCTAssertEqual(ContractType.noMales.rawValue, "Erkek Almaz")
        XCTAssertEqual(ContractType.lastTwo.rawValue, "Son İki")
        XCTAssertEqual(ContractType.rifki.rawValue, "Rıfkı")
        XCTAssertEqual(ContractType.trumpSpades.rawValue, "Maça Koz")
        XCTAssertEqual(ContractType.trumpHearts.rawValue, "Kupa Koz")
        XCTAssertEqual(ContractType.trumpDiamonds.rawValue, "Karo Koz")
        XCTAssertEqual(ContractType.trumpClubs.rawValue, "Sinek Koz")
    }

    func testContractSymbols() {
        XCTAssertEqual(ContractType.noTricks.symbol, "🚫")
        XCTAssertEqual(ContractType.noHearts.symbol, "♥")
        XCTAssertEqual(ContractType.noQueens.symbol, "👑")
        XCTAssertEqual(ContractType.noMales.symbol, "🤴")
        XCTAssertEqual(ContractType.lastTwo.symbol, "2️⃣")
        XCTAssertEqual(ContractType.rifki.symbol, "💀")
        XCTAssertEqual(ContractType.trumpSpades.symbol, "♠")
        XCTAssertEqual(ContractType.trumpHearts.symbol, "♥")
        XCTAssertEqual(ContractType.trumpDiamonds.symbol, "♦")
        XCTAssertEqual(ContractType.trumpClubs.symbol, "♣")
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

        // First selection
        tracker.select(.noTricks, for: player)
        XCTAssertTrue(tracker.canSelectPenalty(.noTricks))

        // Second selection (max reached)
        tracker.select(.noTricks, for: player)
        XCTAssertFalse(tracker.canSelectPenalty(.noTricks))

        // Other penalties still available
        XCTAssertTrue(tracker.canSelectPenalty(.noHearts))
    }

    func testBiddingTrackerTrumpLimit() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        // First 4 rounds no trump allowed
        XCTAssertFalse(tracker.canSelectTrump(player: player, currentRound: 1))
        XCTAssertFalse(tracker.canSelectTrump(player: player, currentRound: 4))

        // Round 5+ trump allowed
        XCTAssertTrue(tracker.canSelectTrump(player: player, currentRound: 5))

        // Select 2 trumps
        tracker.select(.trumpSpades, for: player)
        tracker.select(.trumpHearts, for: player)

        // Third trump not allowed
        XCTAssertFalse(tracker.canSelectTrump(player: player, currentRound: 10))
    }

    func testBiddingTrackerPenaltyPerPlayerLimit() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        // Select 3 penalties
        tracker.select(.noTricks, for: player)
        tracker.select(.noHearts, for: player)
        tracker.select(.noQueens, for: player)

        // Fourth penalty not allowed
        XCTAssertFalse(tracker.canSelectPenalty(player: player))
    }

    func testBiddingTrackerContractsForPlayer() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        tracker.select(.noTricks, for: player)
        tracker.select(.trumpSpades, for: player)

        let contracts = tracker.contracts(for: player)
        XCTAssertEqual(contracts.count, 2)
        XCTAssertTrue(contracts.contains(.noTricks))
        XCTAssertTrue(contracts.contains(.trumpSpades))
    }

    func testBiddingTrackerCountMethods() {
        var tracker = BiddingTracker()
        let player = Player(name: "Test", type: .human)

        tracker.select(.trumpSpades, for: player)
        tracker.select(.trumpHearts, for: player)
        tracker.select(.noTricks, for: player)

        XCTAssertEqual(tracker.trumpCount(for: player), 2)
        XCTAssertEqual(tracker.penaltyCount(for: player), 1)
    }
}
