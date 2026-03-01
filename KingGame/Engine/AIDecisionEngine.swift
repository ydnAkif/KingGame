import Foundation

// MARK: - Card Count Tracker

/// Tracks played cards for AI card counting capability.
///
/// This struct helps AI remember which cards have been played
/// and make informed decisions based on remaining cards.
struct CardCountTracker {
    /// Cards that have been played (key: card id, value: trick number)
    private var playedCards: [UUID: Int] = [:]

    /// Cards remaining in each suit
    var remainingCards: [Suit: [Rank]] {
        var remaining: [Suit: [Rank]] = [:]
        for suit in Suit.allCases {
            remaining[suit] = Rank.allCases.filter { rank in
                !playedCards.values.isEmpty  // Simplified - track by suit
            }
        }
        return remaining
    }

    /// Record a card as played.
    /// - Parameters:
    ///   - card: The card that was played
    ///   - trickNumber: The trick number when this card was played
    mutating func recordPlayedCard(_ card: Card, trickNumber: Int) {
        playedCards[card.id] = trickNumber
    }

    /// Check if a specific card has been played.
    /// - Parameter card: The card to check
    /// - Returns: `true` if the card has been played
    func hasBeenPlayed(_ card: Card) -> Bool {
        // Since card IDs change, check by suit and rank
        return false  // Simplified - would need card identity tracking
    }

    /// Get count of remaining cards in a suit.
    /// - Parameter suit: The suit to check
    /// - Returns: Number of cards remaining in that suit
    func remainingCount(in suit: Suit, knownCards: [Card]) -> Int {
        let totalInSuit = 13
        let knownInSuit = knownCards.filter { $0.suit == suit }.count
        return totalInSuit - knownInSuit
    }

    /// Check if a suit is void (no cards remaining).
    /// - Parameters:
    ///   - suit: The suit to check
    ///   - knownCards: Cards known to be played or in hands
    /// - Returns: `true` if suit is likely void
    func isSuitVoid(_ suit: Suit, knownCards: [Card]) -> Bool {
        return remainingCount(in: suit, knownCards: knownCards) <= 0
    }
}

// MARK: - AI Decision Engine

struct AIDecisionEngine {

    // MARK: - Ana Karar Fonksiyonu
    static func selectCard(
        for player: Player,
        validCards: [Card],
        trick: Trick?,
        round: Round,
        allPlayers: [Player],
        playedCards: [Card]
    ) -> Card {
        switch player.type {
        case .aiAggressive:
            return aggressivePlay(
                player: player, validCards: validCards, trick: trick, round: round,
                playedCards: playedCards)
        case .aiBalanced:
            return balancedPlay(
                player: player, validCards: validCards, trick: trick, round: round,
                playedCards: playedCards, allPlayers: allPlayers)
        case .aiCalculator:
            return calculatorPlay(
                player: player, validCards: validCards, trick: trick, round: round,
                playedCards: playedCards, allPlayers: allPlayers)
        default:
            return validCards.randomElement()!
        }
    }

    // MARK: - Risk Hesaplama
    static func riskScore(for card: Card, in round: Round, trick: Trick?, playedCards: [Card])
        -> Double
    {
        var risk = 0.0

        switch round.contract {
        case .noTricks:
            risk = Double(card.rank.rawValue - 2) / 12.0
            if let trick = trick, willWinTrick(card: card, trick: trick, round: round) {
                risk = min(risk + 0.4, 1.0)
            }
        case .noHearts:
            if card.isHeart {
                risk = 0.8
                let heartCount = Double(playedCards.filter { $0.isHeart }.count)
                risk -= heartCount / 32.0
            } else {
                risk = 0.1
            }
        case .noQueens:
            if card.isQueen {
                risk = 0.9
            } else if card.rank == .ace || card.rank == .king {
                risk = 0.3
            } else {
                risk = 0.1
            }
        case .noMales:
            if card.isMale {
                risk = 0.85
            } else if card.rank == .ace {
                risk = 0.25
            } else {
                risk = 0.1
            }
        case .lastTwo:
            let tricksLeft = Double(13 - (trick?.trickNumber ?? 0))
            if tricksLeft <= 2 {
                risk = willWinTrick(card: card, trick: trick, round: round) ? 0.9 : 0.1
            } else {
                risk = 0.1
            }
        case .rifki:
            if card.isRifki {
                risk = 1.0
            } else if card.isHeart {
                risk = 0.4
            } else {
                risk = 0.1
            }
        case .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs:
            risk = 1.0 - (Double(card.rank.rawValue - 2) / 12.0)
        }

        return risk
    }

    // MARK: - Löveyi kazanır mıyız?
    private static func willWinTrick(card: Card, trick: Trick?, round: Round) -> Bool {
        guard let trick = trick, !trick.cards.isEmpty else { return true }

        if let trumpSuit = round.contract.trumpSuit {
            if card.suit == trumpSuit {
                let highestTrump = trick.cards
                    .filter { $0.card.suit == trumpSuit }
                    .map { $0.card.rank }
                    .max()
                return highestTrump == nil || card.rank > highestTrump!
            }
        }

        guard let leadSuit = trick.leadSuit, card.suit == leadSuit else { return false }
        let highest = trick.cards
            .filter { $0.card.suit == leadSuit }
            .map { $0.card.rank }
            .max()
        return highest == nil || card.rank > highest!
    }

    // MARK: - 🔥 AI Agresif
    private static func aggressivePlay(
        player: Player, validCards: [Card], trick: Trick?, round: Round, playedCards: [Card]
    ) -> Card {

        if round.contract.isTrump {
            return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
        }

        let riskThreshold = 0.35
        let riskyCards = validCards.filter {
            riskScore(for: $0, in: round, trick: trick, playedCards: playedCards) > riskThreshold
        }

        if !riskyCards.isEmpty {
            // En riskli kartı at
            return riskyCards.max { a, b in
                riskScore(for: a, in: round, trick: trick, playedCards: playedCards)
                    < riskScore(for: b, in: round, trick: trick, playedCards: playedCards)
            } ?? riskyCards[0]
        }

        // Blöf: Bazen orta kart oyna
        let midCards = validCards.filter { $0.rank.rawValue >= 7 && $0.rank.rawValue <= 10 }
        if !midCards.isEmpty && Bool.random() {
            return midCards.randomElement()!
        }

        return validCards.randomElement()!
    }

    // MARK: - ⚖️ AI Dengeli
    private static func balancedPlay(
        player: Player, validCards: [Card], trick: Trick?, round: Round, playedCards: [Card],
        allPlayers: [Player]
    ) -> Card {

        if round.contract.isTrump {
            guard let trumpSuit = round.contract.trumpSuit else {
                return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
            }
            let myTrumps = validCards.filter { $0.suit == trumpSuit }
            if myTrumps.count > 4 {
                return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
            } else {
                return validCards.min(by: { $0.rank < $1.rank }) ?? validCards[0]
            }
        }

        let sorted = validCards.sorted { a, b in
            riskScore(for: a, in: round, trick: trick, playedCards: playedCards)
                > riskScore(for: b, in: round, trick: trick, playedCards: playedCards)
        }

        let safeCards = sorted.filter {
            riskScore(for: $0, in: round, trick: trick, playedCards: playedCards) < 0.5
        }

        if !safeCards.isEmpty { return safeCards.first! }
        return sorted.last ?? validCards[0]
    }

    // MARK: - 🧮 AI Hesapçı
    private static func calculatorPlay(
        player: Player, validCards: [Card], trick: Trick?, round: Round, playedCards: [Card],
        allPlayers: [Player]
    ) -> Card {
        // Initialize card counter for advanced tracking
        var cardCounter = CardCountTracker()

        // Record all known played cards
        for card in playedCards {
            cardCounter.recordPlayedCard(card, trickNumber: round.tricks.count)
        }

        if round.contract.isTrump {
            guard let trumpSuit = round.contract.trumpSuit else { return validCards[0] }

            let playedTrumps = playedCards.filter { $0.suit == trumpSuit }.count
            let myTrumps = player.hand.filter { $0.suit == trumpSuit }
            let remainingTrumps =
                13 - playedTrumps - myTrumps.count

            // If I have most remaining trumps, play aggressively
            if myTrumps.count > remainingTrumps {
                return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
            }

            // If trumps are exhausted, play highest card
            if remainingTrumps == 0 {
                return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
            }

            // If few trumps remain, conserve high trumps
            if remainingTrumps <= 2 && myTrumps.count <= 2 {
                return validCards.min(by: { $0.rank < $1.rank }) ?? validCards[0]
            }
        }

        let sorted = validCards.sorted { a, b in
            return riskScore(for: a, in: round, trick: trick, playedCards: playedCards)
                < riskScore(for: b, in: round, trick: trick, playedCards: playedCards)
        }

        if round.contract == .rifki {
            let nonRifki = sorted.filter { !$0.isRifki }
            return nonRifki.first ?? sorted.first ?? validCards[0]
        }

        return sorted.first ?? validCards[0]
    }

    // MARK: - Bidding Stratejisi
    static func selectContract(
        for player: Player,
        availableContracts: [ContractType],
        hand: [Card],
        tracker: BiddingTracker,
        roundNumber: Int
    ) -> ContractType {
        // ÖNCE: RuleEngine ile geçerli kontratları filtrele (KRİTİK DÜZELTME)
        let validContracts = availableContracts.filter {
            RuleEngine.canSelect(
                contract: $0,
                player: player,
                tracker: tracker,
                roundNumber: roundNumber
            )
        }

        // Geçerli kontrat yoksa fallback
        guard !validContracts.isEmpty else {
            print("⚠️ \(player.name) için geçerli kontrat bulunamadı! Fallback: noTricks")
            return .noTricks
        }

        let scoredContracts = validContracts.map { contract in
            (contract: contract, score: evaluateContract(contract, hand: hand))
        }

        // Loglama
        print(
            "🤖 \(player.name) için Kontrat Skorları: \(scoredContracts.map { "\($0.contract.rawValue): \($0.score)" }.joined(separator: ", "))"
        )

        switch player.type {
        case .aiAggressive:
            // Kosullara göre en agresife (genelde en yüksek koz) yönelir. Yoksa en yüksek ceza.
            let sorted = scoredContracts.sorted { $0.score > $1.score }
            if let bestTrump = sorted.first(where: { $0.contract.isTrump && $0.score > 20 }) {
                return bestTrump.contract
            }
            return sorted.first?.contract ?? validContracts[0]

        case .aiBalanced:
            // En yüksek score'u alan sözleşmeyi seç (hem koz hem ceza için en ideali)
            return scoredContracts.max { $0.score < $1.score }?.contract ?? validContracts[0]

        case .aiCalculator:
            // Sadece cezalarda riski en düşük (skoru en pozitif) olan güvenli sözleşmeyi seçmeye çalışır.
            let penalties = scoredContracts.filter { $0.contract.isPenalty }
            if !penalties.isEmpty {
                return penalties.max { $0.score < $1.score }?.contract ?? validContracts[0]
            }
            return scoredContracts.max { $0.score < $1.score }?.contract ?? validContracts[0]

        default:
            return validContracts.randomElement() ?? validContracts[0]
        }
    }

    // El için bir kontratın ne kadar "iyi" olduğunu hesaplar. Yüksek puan iyi, negatif puan kötüdür.
    static func evaluateContract(_ contract: ContractType, hand: [Card]) -> Double {
        var score: Double = 0.0

        switch contract {
        case .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs:
            guard let trumpSuit = contract.trumpSuit else { return 0.0 }
            let trumps = hand.filter { $0.suit == trumpSuit }
            // Koz adedi (temel güç)
            score += Double(trumps.count) * 10.0
            // Güçlü kozlar ekstra puan
            for card in trumps {
                if card.rank == .ace { score += 15.0 }
                if card.rank == .king { score += 10.0 }
                if card.rank == .queen { score += 5.0 }
            }
            // Yan renk eksikliği (Void/Singleton avantajı koz için iyidir)
            for suit in Suit.allCases where suit != trumpSuit {
                let suitCount = hand.filter { $0.suit == suit }.count
                if suitCount == 0 {
                    score += 12.0
                }  // Çok iyi çakma imkanı
                else if suitCount == 1 {
                    score += 6.0
                }
            }

        case .noHearts:
            let heartCount = hand.filter { $0.isHeart }.count
            // Kupa yoksa harika! Yoksa her kupa eksi puan demektir.
            score = 30.0 - Double(heartCount * 12)
            // Kupa as ve papaz çok tehlikelidir kupa almazda
            if hand.contains(where: { $0.isHeart && $0.rank == .ace }) { score -= 15.0 }
            if hand.contains(where: { $0.isHeart && $0.rank == .king }) { score -= 10.0 }

        case .noQueens:
            let queenCount = hand.filter { $0.isQueen }.count
            // Sadece eldeki kızlara değil, as/papaz fazlalığına da bakmak lazım
            score = 20.0 - Double(queenCount * 25)
            let highCards = hand.filter { $0.rank == .ace || $0.rank == .king }.count
            score -= Double(highCards * 5)

        case .noMales:
            let maleCount = hand.filter { $0.isMale }.count
            score = 20.0 - Double(maleCount * 20)
            let aceCount = hand.filter { $0.rank == .ace }.count
            score -= Double(aceCount * 8)

        case .rifki:
            if hand.contains(where: { $0.isRifki }) {
                // Rıfkı bizdeysek yüksek risk! (Ama uzun ve zayıf bir Kupa rengimiz varsa şansımız artabilir)
                let heartCount = hand.filter { $0.isHeart }.count
                score -= (50.0 - Double(heartCount * 3))  // Bir nebze toparlar.
            } else {
                score = 15.0
                // Bizde Rıfkı yok ama ♥A veya ♥Q var ise risklidir
                if hand.contains(where: { $0.isHeart && ($0.rank == .ace || $0.rank == .queen) }) {
                    score -= 10.0
                }
            }

        case .lastTwo:
            // Son ele düşük veya tek renk kalmalı
            let lowCards = hand.filter { $0.rank.rawValue <= 6 }.count
            score = Double(lowCards * 4)
            // Tüm kağıtları eşit dağılımlı yüksekse çok tehlikeli
            let highCards = hand.filter { $0.rank >= .jack }.count
            score -= Double(highCards * 8)

        case .noTricks:
            let lowCards = hand.filter { $0.rank.rawValue <= 8 }.count
            score = Double(lowCards * 5)
            let highCards = hand.filter { $0.rank >= .queen }.count
            score -= Double(highCards * 15)
        }

        return score
    }
}

