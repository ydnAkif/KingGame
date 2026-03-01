import SwiftUI

struct PlayerHandView: View {
    let player: Player
    let validCards: [Card]
    let onCardSelected: (Card) -> Void

    @State private var selectedCard: Card? = nil

    var sortedHand: [Card] {
        player.hand.sorted {
            $0.suit.rawValue == $1.suit.rawValue
                ? $0.rank < $1.rank
                : $0.suit.rawValue < $1.suit.rawValue
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -24) {
                ForEach(sortedHand) { card in
                    let isPlayable = validCards.contains(card)
                    let isSelected = selectedCard?.id == card.id

                    CardView(
                        card: card,
                        isPlayable: isPlayable,
                        isSelected: isSelected,
                        width: 88
                    )
                    .onTapGesture { handleTap(card, isPlayable: isPlayable) }
                    .overlay(
                        // Oynanabilir kart — altın parlaması
                        isPlayable && !isSelected
                        ? RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.goldMid.opacity(0.5), lineWidth: 1.5)
                        : nil
                    )
                    .zIndex(isSelected ? 10 : Double(sortedHand.firstIndex(of: card) ?? 0))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.goldMid.opacity(0.1), lineWidth: 1))
    }

    private func handleTap(_ card: Card, isPlayable: Bool) {
        guard isPlayable else { return }
        if selectedCard?.id == card.id {
            onCardSelected(card)
            selectedCard = nil
        } else {
            selectedCard = card
        }
    }
}
