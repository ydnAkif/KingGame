
//
//  Deck.swift
//  KingGame
//
//  Created by Akif AYDIN on 28.02.2026.
//


import Foundation

struct Deck {
    private(set) var cards: [Card] = []
    
    init() {
        reset()
    }
    
    // 52 kartı oluştur
    mutating func reset() {
        cards = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
    
    // Kartları karıştır (Fisher-Yates)
    mutating func shuffle() {
        cards.shuffle()
    }
    
    // 4 oyuncuya tek tek dağıt (13'er kart)
    mutating func deal() -> [[Card]] {
        shuffle()
        var hands: [[Card]] = [[], [], [], []]
        for (index, card) in cards.enumerated() {
            hands[index % 4].append(card)
        }
        return hands
    }
    
    // Karo 2'yi hangi oyuncu aldı?
    static func findDiamondTwo(in hands: [[Card]]) -> Int {
        for (playerIndex, hand) in hands.enumerated() {
            if hand.contains(where: { $0.suit == .diamonds && $0.rank == .two }) {
                return playerIndex
            }
        }
        return 0 // default
    }
}
