import SwiftUI

struct PlayerHandView: View {
    let player: Player
    let validCards: [Card]
    let onCardSelected: (Card) -> Void

    @State private var selectedCard: Card? = nil
    @State private var hoveredCard: Card? = nil

    // Renklere göre gruplanmış ve sıralanmış el
    var sortedHand: [Card] {
        player.hand.sorted {
            $0.suit.rawValue == $1.suit.rawValue
                ? $0.rank < $1.rank
                : $0.suit.rawValue < $1.suit.rawValue
        }
    }

    var body: some View {
        HStack(spacing: -55) {  // Kartların sayılarının görünmesi için ideal negatif boşluk
            let totalCards = sortedHand.count
            let centerIndex = Double(totalCards - 1) / 2.0

            ForEach(Array(sortedHand.enumerated()), id: \.element.id) { index, card in
                let isPlayable = validCards.contains(card)
                let isSelected = selectedCard?.id == card.id
                let isHovered = hoveredCard?.id == card.id

                // Yelpaze efekti için kavis ve rotasyon hesabı
                let indexOffset = Double(index) - centerIndex
                let cardAngle = indexOffset * 3.5  // Daha dengeli bir dönüş açısı
                let yOffset = abs(indexOffset) * abs(indexOffset) * 1.5  // Kenarlara doğru parabolik bir düşüş

                CardView(
                    card: card,
                    isPlayable: isPlayable,
                    isSelected: isSelected,
                    width: 100  // Tıklanabilir alan için biraz daha optimal genişlik
                )
                .onTapGesture { handleTap(card, isPlayable: isPlayable) }
                .onHover { hovering in
                    if isPlayable {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if hovering {
                                hoveredCard = card
                            } else if hoveredCard?.id == card.id {
                                hoveredCard = nil
                            }
                        }
                    }
                }
                .overlay(
                    isPlayable && !isSelected
                        ? RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color.white.opacity(isHovered ? 0.8 : 0.3),
                                lineWidth: isHovered ? 2.5 : 1.5)
                        : nil
                )
                .rotationEffect(Angle(degrees: cardAngle), anchor: .bottom)
                .offset(y: isSelected ? -30 : (isHovered ? -15 : yOffset))
                .zIndex(isSelected || isHovered ? 100 : Double(index))
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .offset(y: -150).combined(with: .opacity)
                    )
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
            }
        }
        .padding(.top, 40)  // Kalkan kartlar için üstten boşluk
        .padding(.bottom, 25)  // Parabolik kavis için alttan boşluk
        .frame(maxWidth: .infinity)  // Arka plan ekranı yatayda tamamen kaplasın
        .background(
            // Sadece üst köşeleri yuvarlatılmış geniş arka plan
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(Color.black.opacity(0.35))
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .stroke(Color.goldMid.opacity(0.15), lineWidth: 1)
                .ignoresSafeArea(edges: .bottom)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: sortedHand.count)
    }
    private func handleTap(_ card: Card, isPlayable: Bool) {
        guard isPlayable else { return }
        if selectedCard?.id == card.id {
            onCardSelected(card)
            selectedCard = nil
            hoveredCard = nil
        } else {
            selectedCard = card
        }
    }
}
