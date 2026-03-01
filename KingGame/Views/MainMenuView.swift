import SwiftUI

struct MainMenuView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ZStack {
            // Ahşap arka plan
            Color.woodDark.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 10) {
                    // Koz sembolleri
                    HStack(spacing: 16) {
                        Text("♠").font(.system(size: 40)).foregroundColor(.black)
                        Text("♥").font(.system(size: 40)).foregroundColor(Color(red:0.85,green:0.1,blue:0.1))
                        Text("♣").font(.system(size: 40)).foregroundColor(.black)
                        Text("♦").font(.system(size: 40)).foregroundColor(Color(red:0.85,green:0.1,blue:0.1))
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.goldDark.opacity(0.6), radius: 8, x: 0, y: 4)

                    Text("KING")
                        .font(.system(size: 64, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }

                // Oyuncu listesi
                VStack(spacing: 0) {
                    ForEach(Array(gameState.players.enumerated()), id: \.offset) { i, player in
                        HStack(spacing: 12) {
                            // Yön göstergesi
                            Text(["G", "K", "B", "D"][i])
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundColor(Color.goldMid)
                                .frame(width: 20)

                            Image(systemName: player.isAI ? "cpu" : "person.fill")
                                .foregroundColor(player.isAI ? Color.goldMid : .green)

                            Text(player.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text(typeLabel(player.type))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(i % 2 == 0 ? Color.white.opacity(0.05) : Color.clear)
                    }
                }
                .background(Color.black.opacity(0.3))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.goldMid.opacity(0.2), lineWidth: 1))
                .padding(.horizontal, 60)

                // Başlat butonu
                Button(action: { gameState.startGame() }) {
                    Text("OYUNU BAŞLAT")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red:0.15, green:0.08, blue:0.01))
                        .padding(.horizontal, 60)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [Color.goldLight, Color.goldMid, Color.goldDark],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.goldDark.opacity(0.7), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .frame(maxWidth: 500)
        }
    }

    func typeLabel(_ t: PlayerType) -> String {
        switch t {
        case .human:         return "İNSAN"
        case .aiAggressive:  return "AI — AGRESİF"
        case .aiBalanced:    return "AI — DENGELİ"
        case .aiCalculator:  return "AI — HESAPÇI"
        }
    }
}
