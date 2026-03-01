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
        let currentHand = sortedHand
        let totalCards = currentHand.count
        let centerIndex = Double(totalCards - 1) / 2.0
        let hovIndex = currentHand.firstIndex(where: { $0.id == hoveredCard?.id }) ?? -999

        return HStack(spacing: -55) {  // Kartların sayılarının görünmesi için ideal negatif boşluk
            ForEach(Array(currentHand.enumerated()), id: \.element.id) { index, card in
                let isPlayable = validCards.contains(card)
                let isSelected = selectedCard?.id == card.id
                let isHovered = hoveredCard?.id == card.id

                // Yelpaze efekti için kavis ve rotasyon hesabı
                let indexOffset = Double(index) - centerIndex
                let cardAngle = indexOffset * GameConstants.cardFanAngle  // Daha dengeli bir dönüş açısı
                let yOffset = abs(indexOffset) * abs(indexOffset) * 1.5  // Kenarlara doğru parabolik bir düşüş

                // Dock efekti için yanındakileri de hafif büyüt
                let distance = abs(Double(index) - Double(hovIndex))
                let scale: CGFloat =
                    isHovered
                    ? GameConstants.cardHoverScale
                    : (distance == 1.0 ? GameConstants.cardNeighborScale : 1.0)
                let hoverYOffset: CGFloat = isHovered ? -25.0 : (distance == 1.0 ? -10.0 : 0.0)
                let zIndexValue: Double = (isSelected || isHovered) ? 100.0 : Double(index)
                let yFinalOffset: CGFloat =
                    isSelected ? GameConstants.cardSelectOffset : hoverYOffset

                ZStack {
                    // Sabit etkileşim katmanı (görünmez) - Fare titremesini önler
                    // Boyutunu uzun tuttuk ki kart yukarı kalktığında fare boşa düşüp animasyonu bozmasın
                    Rectangle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: 100, height: 180)
                        .offset(y: -20)
                        .onHover { hovering in
                            if isPlayable {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                    if hovering {
                                        hoveredCard = card
                                    } else if hoveredCard?.id == card.id {
                                        hoveredCard = nil
                                    }
                                }
                            }
                        }
                        .onTapGesture { handleTap(card, isPlayable: isPlayable) }

                    // Görsel kart katmanı
                    CardView(
                        card: card,
                        isPlayable: isPlayable,
                        isSelected: isSelected,
                        width: GameConstants.cardWidth
                    )
                    .allowsHitTesting(false)  // Tıklamaları sabit Rectangle'a bırak
                    .overlay(
                        Group {
                            if isPlayable && !isSelected {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color.white.opacity(isHovered ? 0.8 : 0.3),
                                        lineWidth: isHovered ? 2.5 : 1.5
                                    )
                            }
                        }
                    )
                    .scaleEffect(scale)
                    .offset(y: yFinalOffset)
                }
                .rotationEffect(Angle(degrees: cardAngle), anchor: .bottom)
                .offset(y: yOffset)
                .zIndex(zIndexValue)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .offset(y: -150).combined(with: .opacity)
                    )
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hoveredCard)
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
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentHand.count)
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
