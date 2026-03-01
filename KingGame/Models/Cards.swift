import Foundation

// MARK: - Suit (Renk)

/// Represents the four suits in a standard 52-card deck.
///
/// Each suit has a unique symbol and color property (red or black).
enum Suit: String, CaseIterable, Codable {
    case spades = "spades"
    /// ♠ Spades - Black suit
    case hearts = "hearts"
    /// ♥ Hearts - Red suit
    case diamonds = "diamonds"
    /// ♦ Diamonds - Red suit
    case clubs = "clubs"
    /// ♣ Clubs - Black suit

    /// The Unicode symbol for this suit
    var symbol: String {
        switch self {
        case .spades: return "♠"
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        }
    }

    /// Whether this suit is red (hearts or diamonds)
    var isRed: Bool {
        return self == .hearts || self == .diamonds
    }
}

// MARK: - Rank (Değer)

/// Represents the rank of a card from 2 to Ace.
///
/// Ranks are comparable and have both full names and short symbols for display.
enum Rank: Int, CaseIterable, Codable, Comparable {
    case two = 2
    /// 2
    case three = 3
    /// 3
    case four = 4
    /// 4
    case five = 5
    /// 5
    case six = 6
    /// 6
    case seven = 7
    /// 7
    case eight = 8
    /// 8
    case nine = 9
    /// 9
    case ten = 10
    /// 10
    case jack = 11
    /// J - Face card
    case queen = 12
    /// Q - Face card
    case king = 13
    /// K - Face card
    case ace = 14
    /// A - Highest rank

    /// Full English name of the rank
    var name: String {
        switch self {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "jack"
        case .queen: return "queen"
        case .king: return "king"
        case .ace: return "ace"
        }
    }

    /// Short symbol for display (2-10, J, Q, K, A)
    var shortName: String {
        switch self {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }

    /// Compares two ranks by their numeric value
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}

/// Represents a single playing card with a suit and rank.
///
/// Cards are uniquely identified by their UUID and conform to Identifiable
/// for use in SwiftUI lists and collections.
struct Card: Identifiable, Codable, Equatable, Hashable {
    /// Unique identifier for this card instance
    let id: UUID
    /// The suit of this card (spades, hearts, diamonds, or clubs)
    let suit: Suit
    /// The rank of this card (2 through Ace)
    let rank: Rank

    /// Creates a new card with the given suit and rank.
    /// - Parameters:
    ///   - suit: The suit of the card
    ///   - rank: The rank of the card
    init(suit: Suit, rank: Rank) {
        self.id = UUID()
        self.suit = suit
        self.rank = rank
    }

    /// The SVG asset filename for this card (e.g., "spade_1" for Ace of Spades).
    ///
    /// Format: "{suit}_{rank}" where:
    /// - Suit: spade, heart, diamond, club
    /// - Rank: 1 (Ace), 2-10, jack, queen, king
    var imageName: String {
        let rankStr: String
        switch rank {
        case .ace: rankStr = "1"
        case .jack: rankStr = "jack"
        case .queen: rankStr = "queen"
        case .king: rankStr = "king"
        default: rankStr = "\(rank.rawValue)"
        }

        let suitStr: String
        switch suit {
        case .spades: suitStr = "spade"
        case .hearts: suitStr = "heart"
        case .diamonds: suitStr = "diamond"
        case .clubs: suitStr = "club"
        }

        return "\(suitStr)_\(rankStr)"
    }

    /// Whether this card is the King of Hearts (Rıfkı - the most dangerous card).
    ///
    /// In the Rıfkı contract, capturing this card results in -320 points.
    var isRifki: Bool {
        return suit == .hearts && rank == .king
    }

    /// Whether this card is a Queen (Kız).
    ///
    /// In the Kız Almaz contract, each Queen captured is -100 points.
    var isQueen: Bool {
        return rank == .queen
    }

    /// Whether this card is a male card (King or Jack).
    ///
    /// In the Erkek Almaz contract, each male card (4 Kings + 4 Jacks) is -60 points.
    var isMale: Bool {
        return rank == .king || rank == .jack
    }

    /// Whether this card is a Heart.
    ///
    /// In the Kupa Almaz contract, each Heart captured is -30 points.
    var isHeart: Bool {
        return suit == .hearts
    }

    /// Full display name (e.g., "King ♠").
    var displayName: String {
        return "\(rank.name.capitalized) \(suit.symbol)"
    }

    /// Short display name (e.g., "K♠").
    var shortName: String {
        return "\(rank.shortName)\(suit.symbol)"
    }
}
