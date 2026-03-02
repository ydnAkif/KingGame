import Foundation

struct RuleEngine {

    // MARK: - Kontrat Seçim Kontrolü
    static func canSelect(
        contract: ContractType,
        player: Player,
        tracker: BiddingTracker,
        roundNumber: Int
    ) -> Bool {
        if contract.isTrump {
            return tracker.canSelectTrump(player: player, currentRound: roundNumber)
        } else {
            // Oyuncu max 3 ceza seçebilir
            guard tracker.canSelectPenalty(player: player) else { return false }
            // Bu ceza türü max 2 kez seçilebilir
            guard tracker.canSelectPenalty(contract) else { return false }
            return true
        }
    }

    // MARK: - Geçerli Kartlar
    static func validCards(
        for player: Player,
        trick: Trick?,
        round: Round,
        heartsOpened: Bool
    ) -> [Card] {
        let hand = player.hand
        guard !hand.isEmpty else { return [] }

        if round.contract.isTrump {
            return validCardsTrump(hand: hand, trick: trick, round: round)
        } else {
            return validCardsPenalty(
                hand: hand, trick: trick, round: round, heartsOpened: heartsOpened)
        }
    }

    // MARK: - Koz Oyunu Kuralları
    // 1. Renge uymak zorunlu VE mümkünse geçmek zorunlu
    // 2. Renk yoksa koz oynamak zorunlu VE mümkünse geçmek zorunlu
    // 3. Koz açılmadan koz ile löve başlatamazsın
    private static func validCardsTrump(
        hand: [Card],
        trick: Trick?,
        round: Round
    ) -> [Card] {
        guard let trumpSuit = round.contract.trumpSuit else { return hand }

        // Löve başlatıyorsan
        guard let trick = trick, let first = trick.cards.first else {
            if !round.trumpOpened {
                let nonTrump = hand.filter { $0.suit != trumpSuit }
                if !nonTrump.isEmpty { return nonTrump }
            }
            return hand
        }

        let leadSuit = first.card.suit
        let winnerCard = trick.currentWinningCard(trumpSuit: trumpSuit)

        // Aynı renk varsa
        let sameSuit = hand.filter { $0.suit == leadSuit }
        if !sameSuit.isEmpty {
            if let w = winnerCard {
                let higher = sameSuit.filter { beats($0, w, trumpSuit: trumpSuit) }
                if !higher.isEmpty { return higher }
            }
            return sameSuit
        }

        // Renk yok → koz oynamak zorunlu
        let trumpCards = hand.filter { $0.suit == trumpSuit }
        if !trumpCards.isEmpty {
            if let w = winnerCard {
                let higherTrump = trumpCards.filter { beats($0, w, trumpSuit: trumpSuit) }
                if !higherTrump.isEmpty { return higherTrump }
            }
            return trumpCards
        }

        return hand
    }

    private static func beats(_ card: Card, _ winner: Card, trumpSuit: Suit) -> Bool {
        if card.suit == winner.suit { return card.rank > winner.rank }
        if card.suit == trumpSuit && winner.suit != trumpSuit { return true }
        return false
    }

    // MARK: - Ceza Oyunu Kuralları
    private static func validCardsPenalty(
        hand: [Card],
        trick: Trick?,
        round: Round,
        heartsOpened: Bool
    ) -> [Card] {
        guard let trick = trick, let first = trick.cards.first else {
            return validLeadPenalty(hand: hand, round: round, heartsOpened: heartsOpened)
        }
        return validFollowPenalty(hand: hand, trick: trick, leadCard: first.card, round: round)
    }

    private static func validLeadPenalty(hand: [Card], round: Round, heartsOpened: Bool) -> [Card] {
        switch round.contract {
        case .noHearts, .rifki:
            if !heartsOpened {
                let nonHearts = hand.filter { $0.suit != .hearts }
                if !nonHearts.isEmpty { return nonHearts }
            }
            return hand
        default:
            return hand
        }
    }

    private static func validFollowPenalty(hand: [Card], trick: Trick, leadCard: Card, round: Round)
        -> [Card]
    {
        let leadSuit = leadCard.suit
        let sameSuit = hand.filter { $0.suit == leadSuit }

        if !sameSuit.isEmpty {
            // Aynı renk varsa o renkten kural kontrolleri
            if round.contract == .noQueens {
                // Kız Almaz: masada As/K varsa aynı renkte Kız oynamak zorunlu
                let hasHighCard = trick.cards.contains {
                    $0.card.suit == leadSuit && ($0.card.rank == .ace || $0.card.rank == .king)
                }
                if hasHighCard {
                    let queens = sameSuit.filter { $0.isQueen }
                    if !queens.isEmpty { return queens }
                }
            } else if round.contract == .noMales {
                // Erkek Almaz: Masada daha yüksek kağıt varsa erkek atmak zorunlu
                let hasAce = trick.cards.contains { $0.card.suit == leadSuit && $0.card.rank == .ace }
                let hasKing = trick.cards.contains { $0.card.suit == leadSuit && $0.card.rank == .king }
                let hasQueen = trick.cards.contains { $0.card.suit == leadSuit && $0.card.rank == .queen }

                // Yerde As varsa Papaz zorunlu
                if hasAce {
                    let kings = sameSuit.filter { $0.rank == .king }
                    if !kings.isEmpty { return kings }
                }
                // Yerde As, Papaz veya Kız varsa Vale zorunlu
                if hasAce || hasKing || hasQueen {
                    let jacks = sameSuit.filter { $0.rank == .jack }
                    if !jacks.isEmpty { return jacks }
                }
            }
            return sameSuit
        }

        // Renk yoksa: Ceza yedirme zorunlulukları
        switch round.contract {
        case .noHearts:
            // Kupa Almaz: Renk yoksa kupa atmak zorunlu
            let hearts = hand.filter { $0.suit == .hearts }
            if !hearts.isEmpty { return hearts }
            
        case .noQueens:
            // Kız Almaz: Renk yoksa kız atmak zorunlu
            let queens = hand.filter { $0.isQueen }
            if !queens.isEmpty { return queens }
            
        case .noMales:
            // Erkek Almaz: Renk yoksa erkek (Papaz/Vale) atmak zorunlu
            let males = hand.filter { $0.isMale }
            if !males.isEmpty { return males }
            
        case .rifki:
            // Rıfkı: Renk yoksa Rıfkı (Kupa Papazı) atmak zorunlu
            let rifki = hand.filter { $0.isRifki }
            if !rifki.isEmpty { return rifki }
            
        default:
            break
        }

        return hand
    }
}

// MARK: - Trick Uzantısı
extension Trick {
    func currentWinningCard(trumpSuit: Suit) -> Card? {
        guard let first = cards.first else { return nil }
        var winner = first.card
        for play in cards.dropFirst() {
            let c = play.card
            if c.suit == winner.suit && c.rank > winner.rank {
                winner = c
            } else if c.suit == trumpSuit && winner.suit != trumpSuit {
                winner = c
            }
        }
        return winner
    }
}
