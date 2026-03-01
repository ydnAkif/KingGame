import SwiftUI

// MARK: - Yön Sistemi
enum TableDirection: String {
    case south = "Güney"
    case north = "Kuzey"
    case west  = "Batı"
    case east  = "Doğu"
}

struct TrickPileView: View {
    let trick: Trick?
    let directionOf: (Player) -> TableDirection

    var body: some View {
        ZStack {
            // Masa ortası — hafif koyu daire
            Circle()
                .fill(Color.black.opacity(0.12))
                .frame(width: 260, height: 260)

            // Kartlar — her biri kendi yönünde
            if let trick = trick {
                ForEach(Array(trick.cards.enumerated()), id: \.offset) { _, play in
                    let dir = directionOf(play.player)
                    CardView(card: play.card, isPlayable: false, width: 95) // Boyut büyütüldü
                        .offset(offsetFor(dir))
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
        .frame(width: 420, height: 380)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: trick?.cards.count ?? 0)
    }

    func offsetFor(_ dir: TableDirection) -> CGSize {
        switch dir {
        case .south: return CGSize(width: 0,    height: 125)
        case .north: return CGSize(width: 0,    height: -125)
        case .west:  return CGSize(width: -165, height: 0)
        case .east:  return CGSize(width: 165,  height: 0)
        }
    }
}
