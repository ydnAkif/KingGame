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

        let winner = trick.winner(contract: .noTricks)
        XCTAssertEqual(winner?.id, player2.id)
    }

    func testTrickWinnerWithTrump() {
        var trick = Trick(leadSuit: .spades, trickNumber: 1)
        let player1 = Player(name: "P1", type: .human)
        let player2 = Player(name: "P2", type: .aiBalanced)

        trick.cards.append((player: player1, card: Card(suit: .spades, rank: .ace)))
        trick.cards.append((player: player2, card: Card(suit: .hearts, rank: .two)))

        let winner = trick.winner(contract: .trumpHearts)
        XCTAssertEqual(winner?.id, player2.id)
    }

    func testTrickWinnerEmptyTrick() {
        let trick = Trick(leadSuit: .hearts, trickNumber: 1)
        let winner = trick.winner(contract: .noTricks)
        XCTAssertNil(winner)
    }
}
