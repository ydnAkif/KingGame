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

                    CardView(card: play.card, isPlayable: false, width: 95)
                        // Eğer toplanıyorsa (isGathering), hepsi kazananın yönüne uçar, yoksa kendi yönlerinde dururlar.
                        .offset(isGathering ? gatherOffset(winnerDir) : offsetFor(dir))
                        .scaleEffect(isGathering ? 0.4 : 1.0)
                        .opacity(isGathering ? 0.0 : 1.0)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.5).combined(with: .opacity),
                                removal: .opacity
                            ))
                }
            }
        }
        .frame(width: 420, height: 380)
        .animation(.easeInOut(duration: 0.5), value: trick == nil)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: trick?.cards.count ?? 0)
    }

    func offsetFor(_ dir: TableDirection) -> CGSize {
        switch dir {
        case .south: return CGSize(width: 0, height: 125)
        case .north: return CGSize(width: 0, height: -125)
        case .west: return CGSize(width: -165, height: 0)
        case .east: return CGSize(width: 165, height: 0)
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
