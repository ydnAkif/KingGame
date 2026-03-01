import SwiftUI

struct RoundEndView: View {
    @ObservedObject var gameState: GameState

    var sortedPlayers: [Player] {
        gameState.players.sorted { $0.totalScore > $1.totalScore }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Başlık
            VStack(spacing: 6) {
                Text("EL SONUCU")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color.goldMid)
                    .kerning(4)

                Text("\(gameState.roundNumber). El Tamamlandı")
                    .font(.system(size: 32, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 3)
            }
            .padding(.top, 10)

            // Skor tablosu
            scoreTable

            // Butonlar
            HStack(spacing: 20) {
                // Oyundan Çık
                Button(action: {
                    gameState.phase = .setup
                }) {
                    Text("ANA MENÜ")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .contentShape(Capsule())
                .focusable(false)

                // Devam Et
                Button(action: { gameState.startNextRound() }) {
                    Text("SIRADAKİ EL (\(gameState.roundNumber + 1)/20)")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.05, blue: 0.0))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.goldDark.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .contentShape(Capsule())
                .focusable(false)
            }
            .padding(.top, 10)
        }
        .padding(32)
        // Cam efekti ve çift katmanlı arkaplan
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        // Dramatik gölge
        .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
        .shadow(color: Color.goldDark.opacity(0.1), radius: 15, x: 0, y: 0)
        .frame(maxWidth: 600, maxHeight: 600)
    }

    var scoreTable: some View {
        VStack(spacing: 0) {
            // Sabit başlık satırı
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 120, alignment: .leading)
                ForEach(sortedPlayers, id: \.id) { p in
                    Text(p.name.components(separatedBy: "-").first ?? p.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.black.opacity(0.6))

            Divider().background(Color.goldMid.opacity(0.4))

            // Scrollable skor geçmişi
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(gameState.scoreHistory.enumerated()), id: \.offset) { i, entry in
                        ScoreRowView(entry: entry, players: sortedPlayers, isEven: i % 2 == 0)
                    }
                }
            }

            Divider().background(Color.goldMid.opacity(0.5))

            // Sabit TOPLAM satırı
            HStack(spacing: 0) {
                Text("TOPLAM")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color.goldLight)
                    .frame(width: 120, alignment: .leading)

                ForEach(sortedPlayers, id: \.id) { p in
                    Text("\(p.totalScore)")
                        .font(.system(size: 16, weight: .heavy, design: .monospaced))
                        .foregroundColor(
                            p.totalScore >= 0 ? .green : Color(red: 1.0, green: 0.4, blue: 0.4)
                        )
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.black.opacity(0.6))
        }
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(
                Color.goldMid.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Skor Satırı
    struct ScoreRowView: View {
        let entry: ScoreEntry
        let players: [Player]
        let isEven: Bool

        var body: some View {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.contract.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Text(entry.contractOwner)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color.goldMid.opacity(0.8))
                }
                .frame(width: 120, alignment: .leading)

                ForEach(players, id: \.id) { p in
                    ScoreCell(score: entry.scores[p.name] ?? 0)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isEven ? Color.white.opacity(0.04) : Color.clear)
        }
    }

    struct ScoreCell: View {
        let score: Int

        var label: String {
            if score == 0 { return "—" }
            return "\(score > 0 ? "+" : "")\(score)"
        }

        var color: Color {
            if score > 0 { return .green.opacity(0.9) }
            if score < 0 { return Color(red: 1, green: 0.4, blue: 0.4) }
            return .white.opacity(0.2)
        }

        var body: some View {
            Text(label)
                .font(
                    .system(size: 13, weight: score != 0 ? .heavy : .regular, design: .monospaced)
                )
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
        }
    }
}
