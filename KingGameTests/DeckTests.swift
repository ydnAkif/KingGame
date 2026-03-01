import XCTest

@testable import KingGame

// MARK: - Deck Tests
final class DeckTests: XCTestCase {

    func testDeckInitialization() {
        let deck = Deck()
        XCTAssertEqual(deck.cards.count, 52, "Deck should have 52 cards")
    }

    func testDeckHasAllSuits() {
        let deck = Deck()

        let spades = deck.cards.filter { $0.suit == .spades }
        let hearts = deck.cards.filter { $0.suit == .hearts }
        let diamonds = deck.cards.filter { $0.suit == .diamonds }
        let clubs = deck.cards.filter { $0.suit == .clubs }

        XCTAssertEqual(spades.count, 13)
        XCTAssertEqual(hearts.count, 13)
        XCTAssertEqual(diamonds.count, 13)
        XCTAssertEqual(clubs.count, 13)
    }

    func testDeckHasAllRanks() {
        let deck = Deck()

        for suit in Suit.allCases {
            let cards = deck.cards.filter { $0.suit == suit }
            let ranks = cards.map { $0.rank }.sorted()
            XCTAssertEqual(ranks, Rank.allCases.sorted())
        }
    }

    func testDeckReset() {
        var deck = Deck()
        deck.shuffle()
        let shuffledCount = deck.cards.count

        deck.reset()
        XCTAssertEqual(deck.cards.count, 52)
        XCTAssertEqual(shuffledCount, deck.cards.count)
    }

    func testDeckShuffle() {
        var deck1 = Deck()
        var deck2 = Deck()

        deck1.shuffle()
        deck2.shuffle()

        // Probability of same order is extremely low
        XCTAssertNotEqual(deck1.cards.map { $0.id }, deck2.cards.map { $0.id })
    }

    func testDeckDeal() {
        var deck = Deck()
        let hands = deck.deal()

        XCTAssertEqual(hands.count, 4, "Should deal to 4 players")
        XCTAssertEqual(hands[0].count, 13)
        XCTAssertEqual(hands[1].count, 13)
        XCTAssertEqual(hands[2].count, 13)
        XCTAssertEqual(hands[3].count, 13)
    }

    func testDeckDealAllCardsDistributed() {
        var deck = Deck()
        let hands = deck.deal()

        let totalCards = hands.flatMap { $0 }.count
        XCTAssertEqual(totalCards, 52, "All 52 cards should be distributed")
    }

    func testDeckDealNoDuplicateCards() {
        var deck = Deck()
        let hands = deck.deal()

        let allCards = hands.flatMap { $0 }
        let uniqueCards = Set(allCards.map { $0.id })

        XCTAssertEqual(allCards.count, uniqueCards.count, "No duplicate cards should exist")
    }

    func testFindDiamondTwo() {
        var deck = Deck()
        let hands = deck.deal()

        let finderIndex = Deck.findDiamondTwo(in: hands)
        XCTAssertNotNil(finderIndex, "Should find the player with 2 of diamonds")

        if let index = finderIndex {
            let playerHasDiamondTwo = hands[index].contains {
                $0.suit == .diamonds && $0.rank == .two
            }
            XCTAssertTrue(playerHasDiamondTwo)
        }
    }

    func testFindDiamondTwoNotFound() {
        let emptyHands: [[Card]] = [[], [], [], []]
        let result = Deck.findDiamondTwo(in: emptyHands)
        XCTAssertNil(result)
    }

    func testFindDiamondTwoInSpecificHand() {
        let diamondTwo = Card(suit: .diamonds, rank: .two)
        let hands: [[Card]] = [
            [diamondTwo],
            [],
            [],
            [],
        ]

        let result = Deck.findDiamondTwo(in: hands)
        XCTAssertEqual(result, 0)
    }
}
