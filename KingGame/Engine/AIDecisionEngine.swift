import Foundation

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
            return aggressivePlay(player: player, validCards: validCards, trick: trick, round: round, playedCards: playedCards)
        case .aiBalanced:
            return balancedPlay(player: player, validCards: validCards, trick: trick, round: round, playedCards: playedCards, allPlayers: allPlayers)
        case .aiCalculator:
            return calculatorPlay(player: player, validCards: validCards, trick: trick, round: round, playedCards: playedCards, allPlayers: allPlayers)
        default:
            return validCards.randomElement()!
        }
    }
    
    // MARK: - Risk Hesaplama
    static func riskScore(for card: Card, in round: Round, trick: Trick?, playedCards: [Card]) -> Double {
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
    private static func aggressivePlay(player: Player, validCards: [Card], trick: Trick?, round: Round, playedCards: [Card]) -> Card {
        
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
                riskScore(for: a, in: round, trick: trick, playedCards: playedCards) <
                riskScore(for: b, in: round, trick: trick, playedCards: playedCards)
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
    private static func balancedPlay(player: Player, validCards: [Card], trick: Trick?, round: Round, playedCards: [Card], allPlayers: [Player]) -> Card {
        
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
            riskScore(for: a, in: round, trick: trick, playedCards: playedCards) >
            riskScore(for: b, in: round, trick: trick, playedCards: playedCards)
        }
        
        let safeCards = sorted.filter {
            riskScore(for: $0, in: round, trick: trick, playedCards: playedCards) < 0.5
        }
        
        if !safeCards.isEmpty { return safeCards.first! }
        return sorted.last ?? validCards[0]
    }
    
    // MARK: - 🧮 AI Hesapçı
    private static func calculatorPlay(player: Player, validCards: [Card], trick: Trick?, round: Round, playedCards: [Card], allPlayers: [Player]) -> Card {
        
        if round.contract.isTrump {
            guard let trumpSuit = round.contract.trumpSuit else { return validCards[0] }
            
            let playedTrumps = playedCards.filter { $0.suit == trumpSuit }.count
            let remainingTrumps = 13 - playedTrumps - player.hand.filter { $0.suit == trumpSuit }.count
            
            if remainingTrumps == 0 {
                return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
            }
            
            let myTrumps = player.hand.filter { $0.suit == trumpSuit }
            if myTrumps.count > remainingTrumps {
                return validCards.max(by: { $0.rank < $1.rank }) ?? validCards[0]
            }
        }
        
        let sorted = validCards.sorted { a, b in
            return riskScore(for: a, in: round, trick: trick, playedCards: playedCards) <
                   riskScore(for: b, in: round, trick: trick, playedCards: playedCards)
        }
        
        if round.contract == .rifki {
            let nonRifki = sorted.filter { !$0.isRifki }
            return nonRifki.first ?? sorted.first ?? validCards[0]
        }
        
        return sorted.first ?? validCards[0]
    }
    
    // MARK: - Adaptif Strateji
    static func adaptiveStrategy(for player: Player, roundNumber: Int) -> String {
        guard roundNumber % 5 == 0 else { return "normal" }
        if player.totalScore < -400 { return "risky" }
        else if player.totalScore < 0 { return "balanced" }
        else { return "protective" }
    }
    
    // MARK: - Bidding Stratejisi
    static func selectContract(for player: Player, availableContracts: [ContractType], hand: [Card], tracker: BiddingTracker) -> ContractType {
        switch player.type {
        case .aiAggressive:
            let trumps = availableContracts.filter { $0.isTrump }
            if !trumps.isEmpty { return bestTrumpContract(for: hand, from: trumps) }
            return availableContracts.randomElement() ?? availableContracts[0]
        case .aiBalanced:
            return bestContract(for: hand, from: availableContracts)
        case .aiCalculator:
            return safestContract(for: hand, from: availableContracts)
        default:
            return availableContracts[0]
        }
    }
    
    private static func bestTrumpContract(for hand: [Card], from contracts: [ContractType]) -> ContractType {
        var bestContract = contracts[0]
        var maxCount = 0
        for contract in contracts {
            guard let suit = contract.trumpSuit else { continue }
            let count = hand.filter { $0.suit == suit }.count
            if count > maxCount { maxCount = count; bestContract = contract }
        }
        return bestContract
    }
    
    private static func bestContract(for hand: [Card], from contracts: [ContractType]) -> ContractType {
        let heartCount = hand.filter { $0.isHeart }.count
        if heartCount <= 2 && contracts.contains(.noHearts) { return .noHearts }
        let queenCount = hand.filter { $0.isQueen }.count
        if queenCount == 0 && contracts.contains(.noQueens) { return .noQueens }
        if !hand.contains(where: { $0.isRifki }) && contracts.contains(.rifki) { return .rifki }
        return contracts.randomElement() ?? contracts[0]
    }
    
    private static func safestContract(for hand: [Card], from contracts: [ContractType]) -> ContractType {
        var safest = contracts[0]
        var lowestRisk = Double.infinity
        for contract in contracts {
            let risk = contractRisk(for: hand, contract: contract)
            if risk < lowestRisk { lowestRisk = risk; safest = contract }
        }
        return safest
    }
    
    private static func contractRisk(for hand: [Card], contract: ContractType) -> Double {
        switch contract {
        case .noHearts:  return Double(hand.filter { $0.isHeart }.count) * 0.15
        case .noQueens:  return Double(hand.filter { $0.isQueen }.count) * 0.3
        case .noMales:   return Double(hand.filter { $0.isMale }.count) * 0.2
        case .rifki:     return hand.contains(where: { $0.isRifki }) ? 1.0 : 0.1
        case .lastTwo:   return 0.3
        case .noTricks:
            let highCards = hand.filter { $0.rank >= .queen }.count
            return Double(highCards) * 0.15
        default: return 0.5
        }
    }
}
