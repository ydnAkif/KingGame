import XCTest

@testable import KingGame

// MARK: - Round Tests
final class RoundTests: XCTestCase {

    func testRoundInitialization() {
        let owner = Player(name: "Test", type: .human)
        let round = Round(roundNumber: 1, contract: .noTricks, contractOwner: owner)

        XCTAssertEqual(round.roundNumber, 1)
        XCTAssertEqual(round.contract, .noTricks)
        XCTAssertEqual(round.tricks.count, 0)
        XCTAssertNil(round.currentTrick)
        XCTAssertFalse(round.heartsOpened)
        XCTAssertFalse(round.isComplete)
    }

    func testRoundTotalTricks() {
        let owner = Player(name: "Test", type: .human)
        let round = Round(roundNumber: 1, contract: .noTricks, contractOwner: owner)

        XCTAssertEqual(round.totalTricks, 13)
    }

    func testRoundCurrentTrickNumber() {
        let owner = Player(name: "Test", type: .human)
        var round = Round(roundNumber: 1, contract: .noTricks, contractOwner: owner)

        XCTAssertEqual(round.currentTrickNumber, 1)

        round.tricks.append(Trick(leadSuit: .hearts, trickNumber: 1))
        XCTAssertEqual(round.currentTrickNumber, 2)
    }

    func testRoundIsLastTwo() {
        let owner = Player(name: "Test", type: .human)
        let round = Round(roundNumber: 1, contract: .lastTwo, contractOwner: owner)

        XCTAssertFalse(round.isLastTwo(trickNumber: 10))
        XCTAssertTrue(round.isLastTwo(trickNumber: 12))
        XCTAssertTrue(round.isLastTwo(trickNumber: 13))
    }
}
