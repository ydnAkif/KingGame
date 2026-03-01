import SwiftUI

struct MainMenuView: View {
    @ObservedObject var gameState: GameState
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo Bölümü
            VStack(spacing: 5) { // Tac ile KING yazısı arasındaki boşluğu azalttık
                // Kral Tacı
                Image(systemName: "crown.fill")
                    .font(.system(size: 80)) // Taç boyutunu büyüttük
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.goldDark.opacity(0.8), radius: 15, x: 0, y: 5)
                    .padding(.bottom, -10) // Tacın altından KING yazısına biraz daha yaklaşması için

                Text("KING")
                    .font(.system(size: 84, weight: .heavy, design: .serif)) // Yazıyı da biraz büyüttük
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 3)
            }

            // Oyuncu Listesi Paneli (Glassmorphism)
            VStack(spacing: 0) {
                ForEach(Array(gameState.players.enumerated()), id: \.offset) { i, player in
                    HStack(spacing: 16) {
                        // Yön göstergesi
                        Text(["G", "K", "B", "D"][i])
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color.goldLight)
                            .frame(width: 24)

                        Image(systemName: player.isAI ? "cpu" : "person.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(player.isAI ? Color.goldMid : .green)

                        Text(player.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        Text(typeLabel(player.type))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(i % 2 == 0 ? Color.white.opacity(0.04) : Color.clear)
                }
            }
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 60)

            // Başlat Butonu
            Button(action: { gameState.startGame() }) {
                Text("OYUNU BAŞLAT")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red:0.1, green:0.05, blue:0.0))
                    .padding(.horizontal, 60)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(isHovered ? 0.6 : 0.2), lineWidth: isHovered ? 2 : 1)
                    )
                    .shadow(color: Color.goldDark.opacity(isHovered ? 0.8 : 0.4), radius: isHovered ? 15 : 8, x: 0, y: isHovered ? 8 : 4)
            }
            .buttonStyle(.plain)
            .contentShape(Capsule())
            .focusable(false)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }

            Spacer()
        }
        .frame(maxWidth: 550)
    }

    func typeLabel(_ t: PlayerType) -> String {
        switch t {
        case .human:         return "İNSAN"
        case .aiAggressive:  return "AI: AGRESİF"
        case .aiBalanced:    return "AI: DENGELİ"
        case .aiCalculator:  return "AI: HESAPÇI"
        }
    }
}
