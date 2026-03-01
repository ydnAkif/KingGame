import XCTest

@testable import KingGame

// MARK: - Trick Tests
final class TrickTests: XCTestCase {

    func testTrickInitialization() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        XCTAssertEqual(trick.cards.count, 0)
        XCTAssertEqual(trick.leadSuit, .hearts)
        XCTAssertEqual(trick.trickNumber, 1)
    }

    func testTrickAllCards() {
        var trick = Trick(leadSuit: .hearts, trickNumber: 1)
        let player = Player(name: "Test", type: .human)
        let card1 = Card(suit: .hearts, rank: .ace)
        let card2 = Card(suit: .hearts, rank: .king)

        trick.cards.append((player: player, card: card1))
        trick.cards.append((player: player, card: card2))

        XCTAssertEqual(trick.allCards.count, 2)
        XCTAssertTrue(trick.allCards.contains(card1))
        XCTAssertTrue(trick.allCards.contains(card2))
    }

    func testTrickContainsRifki() {
        var trick = Trick(leadSuit: .hearts, trickNumber: 1)
        let player = Player(name: "Test", type: .human)

        trick.cards.append((player: player, card: Card(suit: .hearts, rank: .king)))
        XCTAssertTrue(trick.containsRifki)

        var trick2 = Trick(leadSuit: .spades, trickNumber: 2)
        trick2.cards.append((player: player, card: Card(suit: .spades, rank: .ace)))
        XCTAssertFalse(trick2.containsRifki)
    }

    func testTrickWinnerNoTrump() {
        var trick = Trick(leadSuit: .hearts, trickNumber: 1)
        let player1 = Player(name: "P1", type: .human)
        let player2 = Player(name: "P2", type: .aiBalanced)

        trick.cards.append((player: player1, card: Card(suit: .hearts, rank: .ten)))
        trick.cards.append((player: player2, card: Card(suit: .hearts, rank: .queen)))

        let contract = ContractType.noTricks
        let winner = trick.winner(contract: contract)

        XCTAssertEqual(winner, player2)
    }

    func testTrickWinnerWithTrump() {
        var trick = Trick(leadSuit: .spades, trickNumber: 1)
        let player1 = Player(name: "P1", type: .human)
        let player2 = Player(name: "P2", type: .aiBalanced)

        trick.cards.append((player: player1, card: Card(suit: .spades, rank: .ace)))
        trick.cards.append((player: player2, card: Card(suit: .hearts, rank: .two)))

        let contract = ContractType.trumpHearts
        let winner = trick.winner(contract: contract)

        XCTAssertEqual(winner, player2)  // Trump wins
    }

    func testTrickWinnerEmptyTrick() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        let contract = ContractType.noTricks
        let winner = trick.winner(contract: contract)

        XCTAssertNil(winner)
    }

    func testTrickWinnerHighestCard() {
        var trick = Trick(leadSuit: .diamonds, trickNumber: 1)
        let player1 = Player(name: "P1", type: .human)
        let player2 = Player(name: "P2", type: .aiBalanced)
        let player3 = Player(name: "P3", type: .aiAggressive)

        trick.cards.append((player: player1, card: Card(suit: .diamonds, rank: .ten)))
        trick.cards.append((player: player2, card: Card(suit: .diamonds, rank: .queen)))
        trick.cards.append((player: player3, card: Card(suit: .diamonds, rank: .king)))

        let contract = ContractType.noTricks
        let winner = trick.winner(contract: contract)

        XCTAssertEqual(winner, player3)
    }
}

// MARK: - Round Tests
final class RoundTests: XCTestCase {

    func testRoundInitialization() {
        let owner = Player(name: "Test", type: .human)
        let round = Round(roundNumber: 1, contract: .noTricks, contractOwner: owner)

        XCTAssertEqual(round.roundNumber, 1)
        XCTAssertEqual(round.contract, .noTricks)
        XCTAssertEqual(round.contractOwner, owner)
        XCTAssertEqual(round.tricks.count, 0)
        XCTAssertNil(round.currentTrick)
        XCTAssertFalse(round.heartsOpened)
        XCTAssertFalse(round.isComplete)
        XCTAssertFalse(round.trumpOpened)
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
