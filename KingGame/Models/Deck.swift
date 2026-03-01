import Foundation

struct Deck {
    private(set) var cards: [Card] = []

    init() {
        reset()
    }

    // Create 52 cards
    mutating func reset() {
        cards = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }

    // Shuffle the cards (Fisher-Yates)
    mutating func shuffle() {
        cards.shuffle()
    }

    // Deal the cards to 4 players (13 each)
    mutating func deal() -> [[Card]] {
        shuffle()
        var hands: [[Card]] = [[], [], [], []]
        for (index, card) in cards.enumerated() {
            hands[index % 4].append(card)
        }
        return hands
    }

    // Which player has the 2 of diamonds? Returns nil if not found
    static func findDiamondTwo(in hands: [[Card]]) -> Int? {
        for (playerIndex, hand) in hands.enumerated() {
            if hand.contains(where: { $0.suit == .diamonds && $0.rank == .two }) {
                return playerIndex
            }
        }
        return nil
    }
}
