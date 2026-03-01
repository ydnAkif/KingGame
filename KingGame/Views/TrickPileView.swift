//
//  TrickPile.swift
//  KingGame
//
//  Created by Akif AYDIN on 28.02.2026.
//

//
//  PlayerHandView.swift
//  KingGame
//
//  Created by Akif AYDIN on 28.02.2026.
//

import SwiftUI

struct TrickPileView: View {
    let trick: Trick?
    let playerNames: [UUID: String]
    
    var body: some View {
        ZStack {
            // Masa zemini
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.13, green: 0.37, blue: 0.18).opacity(0.8))
                .frame(width: 320, height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            if let trick = trick {
                // 4 kart pozisyonu (Kuzey, Doğu, Güney, Batı)
                ForEach(Array(trick.cards.enumerated()), id: \.offset) { index, play in
                    CardView(card: play.card, width: 60)
                        .offset(cardOffset(for: index))
                        .rotationEffect(.degrees(cardRotation(for: index)))
                        .transition(.scale.combined(with: .opacity))
                }
            } else {
                Text("Kart oynayın")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trick?.cards.count)
    }
    
    // Kart pozisyonları (masanın 4 yönü)
    private func cardOffset(for index: Int) -> CGSize {
        switch index {
        case 0: return CGSize(width: 0, height: -65)    // Kuzey (karşı AI)
        case 1: return CGSize(width: 85, height: 0)     // Doğu (sağ AI)
        case 2: return CGSize(width: 0, height: 65)     // Güney (insan)
        case 3: return CGSize(width: -85, height: 0)    // Batı (sol AI)
        default: return .zero
        }
    }
    
    private func cardRotation(for index: Int) -> Double {
        switch index {
        case 0: return 180
        case 1: return 270
        case 2: return 0
        case 3: return 90
        default: return 0
        }
    }
}
