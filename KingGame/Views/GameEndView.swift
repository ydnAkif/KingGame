import SwiftUI

struct GameEndView: View {
    @ObservedObject var gameState: GameState

    var sortedPlayers: [Player] {
        gameState.players.sorted { $0.totalScore > $1.totalScore }
    }

    var body: some View {
        ZStack {
            Color.woodDark.ignoresSafeArea()

            VStack(spacing: 16) {
                // Başlık
                Text("OYUN BİTTİ")
                    .font(.system(size: 36, weight: .heavy, design: .serif))
                    .foregroundColor(.white)
                    .padding(.top, 12)

                // Skor tablosu — ScrollView ile
                scoreTable

                // Tekrar oyna
                Button(action: { gameState.startGame() }) {
                    Text("YENİDEN OYNA")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red:0.15,green:0.08,blue:0.01))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(11)
                        .shadow(color: Color.goldDark.opacity(0.6), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 32)
        }
    }

    var scoreTable: some View {
        VStack(spacing: 0) {
            // Sabit başlık satırı
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 110, alignment: .leading)
                ForEach(sortedPlayers, id: \.id) { p in
                    HStack(spacing: 4) {
                        if gameState.gameWinners.contains(where: { $0.id == p.id }) {
                            Text("👑").font(.system(size: 12))
                        }
                        Text(p.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.black.opacity(0.5))

            Divider().background(Color.goldMid.opacity(0.3))

            // Scrollable skor geçmişi
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(gameState.scoreHistory.enumerated()), id: \.offset) { i, entry in
                        ScoreRowView(entry: entry, players: sortedPlayers, isEven: i % 2 == 0)
                    }
                }
            }

            Divider().background(Color.goldMid.opacity(0.3))

            // Sabit TOPLAM satırı
            HStack(spacing: 0) {
                Text("TOPLAM")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color.goldLight)
                    .frame(width: 110, alignment: .leading)

                ForEach(sortedPlayers, id: \.id) { p in
                    Text("\(p.totalScore)")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundColor(p.totalScore >= 0 ? .green : Color(red:1,green:0.3,blue:0.3))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.black.opacity(0.5))
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.goldMid.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Skor Satırı
    struct ScoreRowView: View {
        let entry: ScoreEntry
        let players: [Player]
        let isEven: Bool

        var body: some View {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.contract.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    Text(entry.contractOwner)
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(width: 110, alignment: .leading)

                ForEach(players, id: \.id) { p in
                    ScoreCell(score: entry.scores[p.name] ?? 0)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
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
            if score > 0 { return .green }
            if score < 0 { return Color(red: 1, green: 0.3, blue: 0.3) }
            return .white.opacity(0.3)
        }

        var body: some View {
            Text(label)
                .font(.system(size: 11, weight: score != 0 ? .bold : .regular, design: .monospaced))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
        }
    }
}
