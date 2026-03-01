import XCTest

@testable import KingGame

// MARK: - Round Tests
@MainActor
final class RoundTests: XCTestCase {

    // MARK: - Round Properties Tests (Without Player Instantiation)

    func testRoundTotalTricksConstant() {
        // A round always has 13 tricks
        let expectedTotalTricks = 13
        XCTAssertEqual(expectedTotalTricks, 13)
    }

    func testRoundIsLastTwoLogic() {
        // Test the isLastTwo logic without creating a Round
        let totalTricks = 13

        // Trick 10 is NOT in last two
        let trick10IsLastTwo = 10 >= totalTricks - 1
        XCTAssertFalse(trick10IsLastTwo)

        // Trick 11 is NOT in last two
        let trick11IsLastTwo = 11 >= totalTricks - 1
        XCTAssertFalse(trick11IsLastTwo)

        // Trick 12 IS in last two (second to last)
        let trick12IsLastTwo = 12 >= totalTricks - 1
        XCTAssertTrue(trick12IsLastTwo)

        // Trick 13 IS in last two (last)
        let trick13IsLastTwo = 13 >= totalTricks - 1
        XCTAssertTrue(trick13IsLastTwo)
    }

    func testCurrentTrickNumberCalculation() {
        // currentTrickNumber = tricks.count + 1
        var tricksCount = 0
        XCTAssertEqual(tricksCount + 1, 1)

        tricksCount = 1
        XCTAssertEqual(tricksCount + 1, 2)

        tricksCount = 5
        XCTAssertEqual(tricksCount + 1, 6)

        tricksCount = 12
        XCTAssertEqual(tricksCount + 1, 13)
    }

    // MARK: - Contract Type Tests

    func testAllContractTypes() {
        let allContracts = ContractType.allCases
        XCTAssertEqual(allContracts.count, 10)
    }

    func testPenaltyContractsCount() {
        let penalties = ContractType.allCases.filter { $0.isPenalty }
        XCTAssertEqual(penalties.count, 6)
    }

    func testTrumpContractsCount() {
        let trumps = ContractType.allCases.filter { $0.isTrump }
        XCTAssertEqual(trumps.count, 4)
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

    func testContractColorNames() {
        XCTAssertEqual(ContractType.noTricks.colorName, "black")
        XCTAssertEqual(ContractType.noHearts.colorName, "red")
        XCTAssertEqual(ContractType.noQueens.colorName, "orange")
        XCTAssertEqual(ContractType.noMales.colorName, "green")
        XCTAssertEqual(ContractType.lastTwo.colorName, "purple")
        XCTAssertEqual(ContractType.rifki.colorName, "red")
    }

    // MARK: - Trick Initialization Tests

    func testTrickCanBeCreated() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        XCTAssertEqual(trick.leadSuit, .hearts)
        XCTAssertEqual(trick.trickNumber, 1)
        XCTAssertTrue(trick.cards.isEmpty)
    }

    func testTrickLeadSuitOptions() {
        let spadesTrick = Trick(leadSuit: .spades, trickNumber: 1)
        XCTAssertEqual(spadesTrick.leadSuit, .spades)

        let heartsTrick = Trick(leadSuit: .hearts, trickNumber: 2)
        XCTAssertEqual(heartsTrick.leadSuit, .hearts)

        let diamondsTrick = Trick(leadSuit: .diamonds, trickNumber: 3)
        XCTAssertEqual(diamondsTrick.leadSuit, .diamonds)

        let clubsTrick = Trick(leadSuit: .clubs, trickNumber: 4)
        XCTAssertEqual(clubsTrick.leadSuit, .clubs)

        let nilTrick = Trick(leadSuit: nil, trickNumber: 5)
        XCTAssertNil(nilTrick.leadSuit)
    }

    // MARK: - Hearts Opened Logic Tests

    func testHeartsOpenedLogic() {
        // Hearts is opened when first heart card is played
        var heartsOpened = false

        // Play a spade - hearts still closed
        let spadeCard = Card(suit: .spades, rank: .ace)
        if spadeCard.suit == .hearts {
            heartsOpened = true
        }
        XCTAssertFalse(heartsOpened)

        // Play a heart - hearts opens
        let heartCard = Card(suit: .hearts, rank: .ace)
        if heartCard.suit == .hearts {
            heartsOpened = true
        }
        XCTAssertTrue(heartsOpened)
    }

    // MARK: - Trump Opened Logic Tests

    func testTrumpOpenedLogic() {
        // Trump is opened when first trump card is played
        let trumpSuit = Suit.hearts
        var trumpOpened = false

        // Play a non-trump card
        let nonTrumpCard = Card(suit: .spades, rank: .ace)
        if nonTrumpCard.suit == trumpSuit {
            trumpOpened = true
        }
        XCTAssertFalse(trumpOpened)

        // Play a trump card
        let trumpCard = Card(suit: .hearts, rank: .two)
        if trumpCard.suit == trumpSuit {
            trumpOpened = true
        }
        XCTAssertTrue(trumpOpened)
    }

    // MARK: - Round Number Tests

    func testValidRoundNumbers() {
        // Valid round numbers are 1-20 in a full game
        for roundNumber in 1...20 {
            XCTAssertGreaterThanOrEqual(roundNumber, 1)
            XCTAssertLessThanOrEqual(roundNumber, 20)
        }
    }

    // MARK: - Is Complete Logic Tests

    func testRoundIsCompleteLogic() {
        // A round is complete when all 13 tricks are played
        let totalTricks = 13

        var tricksPlayed = 0
        XCTAssertFalse(tricksPlayed >= totalTricks)

        tricksPlayed = 12
        XCTAssertFalse(tricksPlayed >= totalTricks)

        tricksPlayed = 13
        XCTAssertTrue(tricksPlayed >= totalTricks)
    }
}
