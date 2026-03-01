//
//  Round.swift
//  KingGame
//
//  Created by Akif AYDIN on 28.02.2026.
//

import Foundation

struct Round {
    var roundNumber: Int
    var contract: ContractType
    var contractOwner: Player
    var tricks: [Trick] = []
    var currentTrick: Trick?
    var heartsOpened: Bool = false
    var isComplete: Bool = false
    var trumpOpened: Bool = false
    
    var totalTricks: Int { return 13 }
    var currentTrickNumber: Int { return tricks.count + 1 }
    
    func isLastTwo(trickNumber: Int) -> Bool {
        return trickNumber >= totalTricks - 1
    }
}
