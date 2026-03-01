import Foundation

// MARK: - Suit (Renk)

enum Suit: String, CaseIterable, Codable {
    case spades = "spades"
    case hearts = "hearts"
    case diamonds = "diamonds"
    case clubs = "clubs"

    var symbol: String {
        switch self {
        case .spades: return "♠"
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        }
    }

    var isRed: Bool {
        return self == .hearts || self == .diamonds
    }
}

// MARK: - Rank (Değer)

enum Rank: Int, CaseIterable, Codable, Comparable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14

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

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}

struct Card: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let suit: Suit
    let rank: Rank

    init(suit: Suit, rank: Rank) {
        self.id = UUID()
        self.suit = suit
        self.rank = rank
    }
    // SVG asset ismi: "ace_of_spades", "king_of_hearts" vb.
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
    // Kupa Papaz mı? (Rıfkı)
    var isRifki: Bool {
        return suit == .hearts && rank == .king
    }
    // Kız mı? (Queen)
    var isQueen: Bool {
        return rank == .queen
    }

    // Erkek mi? (King veya Jack)
    var isMale: Bool {
        return rank == .king || rank == .jack
    }

    // Kupa mı?
    var isHeart: Bool {
        return suit == .hearts
    }

    var displayName: String {
        return "\(rank.name.capitalized) \(suit.symbol)"
    }

    // Kısa gösterim: "K♠", "Q♥" vb.
    var shortName: String {
        return "\(rank.shortName)\(suit.symbol)"
    }
}
