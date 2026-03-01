//
//  Trick.swift
//  KingGame
//
//  Created by Akif AYDIN on 28.02.2026.
//

import Foundation

struct Trick {
    var cards: [(player: Player, card: Card)] = []
    var leadSuit: Suit?
    var trickNumber: Int
    
    func winner(contract: ContractType) -> Player? {
        guard !cards.isEmpty else { return nil }
        
        if let trump = contract.trumpSuit {
            let trumpCards = cards.filter { $0.card.suit == trump }
            if !trumpCards.isEmpty {
                return trumpCards.max(by: { $0.card.rank < $1.card.rank })?.player
            }
        }
        
        guard let lead = leadSuit else { return nil }
        let leadCards = cards.filter { $0.card.suit == lead }
        return leadCards.max(by: { $0.card.rank < $1.card.rank })?.player
    }
    
    var containsRifki: Bool {
        return cards.contains { $0.card.isRifki }
    }
    
    var allCards: [Card] {
        return cards.map { $0.card }
    }
}
