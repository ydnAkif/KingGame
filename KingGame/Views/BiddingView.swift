import SwiftUI

struct BiddingView: View {
    @ObservedObject var gameState: GameState
    let onContractSelected: (ContractType) -> Void
    private let dummyCard = Card(suit: .spades, rank: .two)

    var body: some View {
        ZStack {
            // Lüks Kumarhane Arkaplanı
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.1, green: 0.35, blue: 0.15), Color.black],
                center: .center,
                startRadius: 50,
                endRadius: 800
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                // Üst alan — Kuzey AI kartları + plaka
                northPreview
                    .padding(.top, 12)

                HStack(spacing: 0) {
                    westPreview
                    // MERKEZ — seçim ekranı
                    centerBidding
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    eastPreview
                }
                .frame(maxHeight: .infinity)

                // Alt — İnsan eli
                southHand
                    .padding(.bottom, 10)
            }
        }
        .frame(minWidth: 1050, minHeight: 780)
    }

    // MARK: - Kuzey Preview
    var northPreview: some View {
        let p = gameState.players[1]
        return VStack(spacing: 6) {
            PlayerInfoPanel(player: p, isActive: false, contract: nil)
            HStack(spacing: -20) {
                ForEach(0..<p.hand.count, id: \.self) { _ in
                    CardView(card: dummyCard, faceDown: true, width: 48)
                }
            }
            .frame(height: 72)
        }
    }

    var westPreview: some View {
        let p = gameState.players[2]
        return VStack(spacing: 6) {
            PlayerInfoPanel(player: p, isActive: false, contract: nil)
            ZStack {
                ForEach(Array(0..<min(p.hand.count, 8)).reversed(), id: \.self) { i in
                    CardView(card: dummyCard, faceDown: true, width: 44)
                        .rotationEffect(.degrees(90))
                        .offset(y: CGFloat(i) * -8)
                }
            }
            .frame(width: 80, height: 180)
        }
        .frame(width: 120)
    }

    var eastPreview: some View {
        let p = gameState.players[3]
        return VStack(spacing: 6) {
            PlayerInfoPanel(player: p, isActive: false, contract: nil)
            ZStack {
                ForEach(Array(0..<min(p.hand.count, 8)).reversed(), id: \.self) { i in
                    CardView(card: dummyCard, faceDown: true, width: 44)
                        .rotationEffect(.degrees(-90))
                        .offset(y: CGFloat(i) * -8)
                }
            }
            .frame(width: 80, height: 180)
        }
        .frame(width: 120)
    }

    // MARK: - Merkez Bidding Paneli
    var centerBidding: some View {
        VStack(spacing: 14) {
            // Kim seçiyor
            VStack(spacing: 4) {
                Text("KONTRAT SEÇİMİ")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .kerning(3)
                Text(gameState.biddingPlayer.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("El \(gameState.roundNumber + 1) / 20")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }

            // İlk tur uyarısı
            if gameState.roundNumber < 4 {
                Text("⚠️ İlk tur — Sadece ceza seçilebilir")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 1, green: 0.7, blue: 0.2))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(red: 1, green: 0.5, blue: 0).opacity(0.15))
                    .cornerRadius(8)
            }

            // KOZ BUTONLARI (ilk 4 elde gizli)
            if gameState.roundNumber >= 4 {
                HStack(spacing: 8) {
                    ForEach(trumpContracts, id: \.self) { c in
                        TrumpButton(contract: c, isAvailable: isAvailable(c)) {
                            onContractSelected(c)
                        }
                    }
                }
            }

            // CEZA BUTONLARI (2x3 grid)
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    PenaltyButton(contract: .noTricks, isAvailable: isAvailable(.noTricks)) {
                        onContractSelected(.noTricks)
                    }
                    PenaltyButton(contract: .noHearts, isAvailable: isAvailable(.noHearts)) {
                        onContractSelected(.noHearts)
                    }
                }
                HStack(spacing: 8) {
                    PenaltyButton(contract: .noMales, isAvailable: isAvailable(.noMales)) {
                        onContractSelected(.noMales)
                    }
                    PenaltyButton(contract: .noQueens, isAvailable: isAvailable(.noQueens)) {
                        onContractSelected(.noQueens)
                    }
                }
                HStack(spacing: 8) {
                    PenaltyButton(contract: .rifki, isAvailable: isAvailable(.rifki)) {
                        onContractSelected(.rifki)
                    }
                    PenaltyButton(contract: .lastTwo, isAvailable: isAvailable(.lastTwo)) {
                        onContractSelected(.lastTwo)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 24)
    }

    // MARK: - Alt — İnsan Eli
    var southHand: some View {
        let human = gameState.players[0]
        let sorted = human.hand.sorted {
            $0.suit.rawValue == $1.suit.rawValue
                ? $0.rank < $1.rank
                : $0.suit.rawValue < $1.suit.rawValue
        }
        let half = (sorted.count + 1) / 2
        let topRow = Array(sorted.prefix(half))
        let bottomRow = Array(sorted.dropFirst(half))

        return VStack(spacing: 6) {
            PlayerInfoPanel(player: human, isActive: true, contract: nil)
            VStack(spacing: 4) {
                biddingCardRow(cards: topRow)
                biddingCardRow(cards: bottomRow)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 12)
    }

    func biddingCardRow(cards: [Card]) -> some View {
        HStack(spacing: -18) {
            ForEach(cards, id: \.id) { card in
                CardView(card: card, isPlayable: true, width: 96)
            }
        }
    }

    // MARK: - Yardımcılar
    var trumpContracts: [ContractType] {
        [.trumpSpades, .trumpHearts, .trumpClubs, .trumpDiamonds]
    }

    func isAvailable(_ c: ContractType) -> Bool {
        guard !gameState.biddingPlayer.isAI else { return false }

        return RuleEngine.canSelect(
            contract: c,
            player: gameState.biddingPlayer,
            tracker: gameState.biddingTracker,
            roundNumber: gameState.roundNumber + 1
        )
    }
}

// MARK: - Koz Butonu (küçük sembol)
struct TrumpButton: View {
    let contract: ContractType
    let isAvailable: Bool
    let action: () -> Void

    var suitColor: Color {
        switch contract {
        case .trumpHearts, .trumpDiamonds: return Color(red: 0.9, green: 0.2, blue: 0.2)
        default: return Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }

    var body: some View {
        Button(action: { if isAvailable { action() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isAvailable
                            ? LinearGradient(
                                colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(isAvailable ? 0.4 : 0.1), lineWidth: 1)
                    )
                    .shadow(
                        color: isAvailable ? Color.goldDark.opacity(0.4) : .clear, radius: 6, x: 0,
                        y: 3)

                Text(contract.symbol)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(isAvailable ? suitColor : Color.white.opacity(0.3))
            }
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}

// MARK: - Ceza Butonu (geniş altın)
struct PenaltyButton: View {
    let contract: ContractType
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: { if isAvailable { action() } }) {
            Text(contract.rawValue.uppercased())
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(
                    isAvailable
                        ? Color(red: 0.15, green: 0.08, blue: 0.01) : Color.white.opacity(0.4)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isAvailable
                                ? LinearGradient(
                                    colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                    startPoint: .top, endPoint: .bottom)
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(isAvailable ? 0.4 : 0.1), lineWidth: 1)
                        )
                        .shadow(
                            color: isAvailable ? Color.goldDark.opacity(0.5) : .clear, radius: 5,
                            x: 0, y: 3)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}
