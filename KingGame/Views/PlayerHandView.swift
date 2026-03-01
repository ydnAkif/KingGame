import SwiftUI

struct PlayerHandView: View {
    let player: Player
    let validCards: [Card]
    let onCardSelected: (Card) -> Void

    @State private var selectedCard: Card? = nil

    // Renklere göre gruplanmış ve sıralanmış el
    var sortedHand: [Card] {
        player.hand.sorted {
            $0.suit.rawValue == $1.suit.rawValue
                ? $0.rank < $1.rank
                : $0.suit.rawValue < $1.suit.rawValue
        }
    }

    // İki sıraya böl: üst sıra ilk yarı, alt sıra ikinci yarı
    var topRow: [Card] {
        let half = (sortedHand.count + 1) / 2
        return Array(sortedHand.prefix(half))
    }

    var bottomRow: [Card] {
        let half = (sortedHand.count + 1) / 2
        return Array(sortedHand.dropFirst(half))
    }

    var body: some View {
        VStack(spacing: 4) {
            cardRow(cards: topRow)
            cardRow(cards: bottomRow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.goldMid.opacity(0.1), lineWidth: 1))
    }

    func cardRow(cards: [Card]) -> some View {
        HStack(spacing: -18) {
            ForEach(cards) { card in
                let isPlayable = validCards.contains(card)
                let isSelected = selectedCard?.id == card.id

                CardView(
                    card: card,
                    isPlayable: isPlayable,
                    isSelected: isSelected,
                    width: 96
                )
                .onTapGesture { handleTap(card, isPlayable: isPlayable) }
                .overlay(
                    isPlayable && !isSelected
                    ? RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.goldMid.opacity(0.5), lineWidth: 1.5)
                    : nil
                )
                .zIndex(isSelected ? 10 : Double(cards.firstIndex(of: card) ?? 0))
            }
        }
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
