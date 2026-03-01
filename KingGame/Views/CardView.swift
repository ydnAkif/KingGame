//
//  CardView.swift
//  KingGame
//
//  Created by Akif AYDIN on 28.02.2026.
//

import SwiftUI

struct CardView: View {
    let card: Card
    var isPlayable: Bool = true
    var isSelected: Bool = false
    var faceDown: Bool = false
    var width: CGFloat = 80
    
    var height: CGFloat { width * 1.4 }
    
    var body: some View {
        ZStack {
            if faceDown {
                backView
            } else {
                frontView
            }
        }
        .frame(width: width, height: height)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .offset(y: isSelected ? -12 : 0)
        .opacity(isPlayable ? 1.0 : 0.7)
        .saturation(isPlayable ? 1.0 : 0.6)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        .shadow(color: isSelected ? .yellow.opacity(0.8) : .black.opacity(0.3),
                radius: isSelected ? 12 : 4, x: 0, y: 2)
    }
    
    // MARK: - Ön Yüz
    var frontView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.yellow : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 0.5)
                )
            
            // SVG resmi
            Image(card.imageName)
                .resizable()
                .scaledToFit()
                .padding(4)
        }
    }
    
    // MARK: - Arka Yüz
    var backView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.2, blue: 0.5),
                                 Color(red: 0.05, green: 0.1, blue: 0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Arka yüz deseni
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .padding(4)
            
            Image("back")
                .resizable()
                .scaledToFit()
                .padding(6)
                .opacity(0.9)
        }
    }
}
