import SwiftUI

// MARK: - Yön Sistemi
enum TableDirection: String {
    case south = "Güney"
    case north = "Kuzey"
    case west = "Batı"
    case east = "Doğu"
}

struct TrickPileView: View {
    let trick: Trick?
    let lastTrick: Trick?
    let lastTrickWinner: Player?
    let directionOf: (Player) -> TableDirection

    var body: some View {
        ZStack {
            // Masa ortası — hafif koyu daire
            Circle()
                .fill(Color.black.opacity(0.12))
                .frame(width: 260, height: 260)

            // Kartlar — her biri kendi yönünde
            let activeTrick = trick ?? lastTrick
            let isGathering = (trick == nil && lastTrick != nil)

            if let active = activeTrick {
                ForEach(Array(active.cards.enumerated()), id: \.offset) { _, play in
                    let dir = directionOf(play.player)
                    let winnerDir = lastTrickWinner != nil ? directionOf(lastTrickWinner!) : .south

                    CardView(card: play.card, isPlayable: false, isDimmed: false, width: 110)
                        // Eğer toplanıyorsa (isGathering), hepsi kazananın yönüne uçar, yoksa kendi yönlerinde dururlar.
                        .offset(isGathering ? gatherOffset(winnerDir) : offsetFor(dir))
                        .scaleEffect(isGathering ? 0.3 : 1.0)
                        .opacity(isGathering ? 0.0 : 1.0)
                        .rotationEffect(.degrees(isGathering ? 180 : 0))  // Toplanırken dönsünler
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.2).combined(with: .opacity).combined(
                                    with: .offset(y: 50)),
                                removal: .opacity
                            ))
                }
            }
        }
        .frame(width: 440, height: 400)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.6), value: trick == nil)  // Toplanma için akıcı Curve
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: trick?.cards.count ?? 0)  // Atılma için zıplamalı
    }

    func offsetFor(_ dir: TableDirection) -> CGSize {
        switch dir {
        case .south: return CGSize(width: 0, height: 130)
        case .north: return CGSize(width: 0, height: -130)
        case .west: return CGSize(width: -170, height: 0)
        case .east: return CGSize(width: 170, height: 0)
        }
    }

    // Toplanma (uçma) efekti için varış noktaları
    func gatherOffset(_ dir: TableDirection) -> CGSize {
        switch dir {
        case .south: return CGSize(width: 0, height: 350)
        case .north: return CGSize(width: 0, height: -350)
        case .west: return CGSize(width: -350, height: 0)
        case .east: return CGSize(width: 350, height: 0)
        }
    }
}
