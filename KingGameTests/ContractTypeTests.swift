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
}
