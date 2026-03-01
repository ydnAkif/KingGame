import SwiftUI

struct BiddingView: View {
    @ObservedObject var gameState: GameState
    let onContractSelected: (ContractType) -> Void

    var body: some View {
        ZStack {
            // MERKEZ MODAL
            VStack(spacing: 20) {
                // Kim seçiyor & Başlık
                VStack(spacing: 6) {
                    Text("KONTRAT SEÇİMİ")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(.goldLight)
                        .kerning(3)

                    Text(gameState.biddingPlayer.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("El \(gameState.roundNumber + 1) / 20")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 10)

                // İlk tur uyarısı
                if gameState.roundNumber < 4 {
                    Text("⚠️ İlk 4 tur sadece ceza seçilebilir")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1, green: 0.8, blue: 0.3))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 1, green: 0.5, blue: 0).opacity(0.2))
                        .cornerRadius(8)
                }

                // KOZ BUTONLARI (ilk 4 elde gizli)
                if gameState.roundNumber >= 4 {
                    HStack(spacing: 12) {
                        ForEach(trumpContracts, id: \.self) { c in
                            TrumpButton(contract: c, isAvailable: isAvailable(c)) {
                                onContractSelected(c)
                            }
                        }
                    }
                    .padding(.bottom, 5)
                }

                // CEZA BUTONLARI (2x3 grid)
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        PenaltyButton(contract: .noTricks, isAvailable: isAvailable(.noTricks)) {
                            onContractSelected(.noTricks)
                        }
                        PenaltyButton(contract: .noHearts, isAvailable: isAvailable(.noHearts)) {
                            onContractSelected(.noHearts)
                        }
                    }
                    HStack(spacing: 12) {
                        PenaltyButton(contract: .noMales, isAvailable: isAvailable(.noMales)) {
                            onContractSelected(.noMales)
                        }
                        PenaltyButton(contract: .noQueens, isAvailable: isAvailable(.noQueens)) {
                            onContractSelected(.noQueens)
                        }
                    }
                    HStack(spacing: 12) {
                        PenaltyButton(contract: .rifki, isAvailable: isAvailable(.rifki)) {
                            onContractSelected(.rifki)
                        }
                        PenaltyButton(contract: .lastTwo, isAvailable: isAvailable(.lastTwo)) {
                            onContractSelected(.lastTwo)
                        }
                    }
                }
            }
            .padding(32)
            // Cam efekti ve çift katmanlı arkaplan
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
            // Yüksek bir modal hissi vermek için dramatik gölge
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 20)
            .shadow(color: Color.goldDark.opacity(0.1), radius: 10, x: 0, y: 0)
            .frame(maxWidth: 500)

            // ALT KISIM - OYUNCUNUN KARTLARI
            VStack {
                Spacer()
                if let human = gameState.players.first(where: { !$0.isAI }) {
                    PlayerHandView(
                        player: human,
                        validCards: [], // İhale aşamasında kart seçilmez
                        onCardSelected: { _ in }
                    )
                    .padding(.bottom, 8)
                }
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

// MARK: - Koz Butonu
struct TrumpButton: View {
    let contract: ContractType
    let isAvailable: Bool
    let action: () -> Void

    @State private var isHovered = false

    var suitColor: Color {
        switch contract {
        case .trumpHearts, .trumpDiamonds: return Color(red: 0.9, green: 0.2, blue: 0.2)
        default: return Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }

    var body: some View {
        Button(action: { if isAvailable { action() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isAvailable
                            ? LinearGradient(
                                colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 72, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(isAvailable ? (isHovered ? 0.8 : 0.4) : 0.1), lineWidth: isHovered && isAvailable ? 2 : 1)
                    )
                    .shadow(color: isAvailable ? Color.goldDark.opacity(isHovered ? 0.6 : 0.3) : .clear, radius: isHovered ? 10 : 5, x: 0, y: isHovered ? 5 : 2)

                Text(contract.symbol)
                    .font(.system(size: 38, weight: .regular))
                    .foregroundColor(isAvailable ? suitColor : Color.white.opacity(0.2))
            }
            .scaleEffect(isHovered && isAvailable ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Ceza Butonu
struct PenaltyButton: View {
    let contract: ContractType
    let isAvailable: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: { if isAvailable { action() } }) {
            Text(contract.rawValue.uppercased())
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(
                    isAvailable
                        ? Color(red: 0.1, green: 0.05, blue: 0.0) : Color.white.opacity(0.3)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
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
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(isAvailable ? (isHovered ? 0.8 : 0.4) : 0.1), lineWidth: isHovered && isAvailable ? 2 : 1)
                        )
                        .shadow(color: isAvailable ? Color.goldDark.opacity(isHovered ? 0.6 : 0.3) : .clear, radius: isHovered ? 10 : 5, x: 0, y: isHovered ? 5 : 2)
                )
                .scaleEffect(isHovered && isAvailable ? 1.03 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
